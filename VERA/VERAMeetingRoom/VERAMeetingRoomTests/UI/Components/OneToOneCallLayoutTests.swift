import SwiftUI
import Testing
import VERADomain
import VERATestHelpers

@testable import VERAMeetingRoom

@Suite("One-to-one layout selection and floating self-view")
@MainActor
struct OneToOneCallLayoutTests {
    private func local() -> UIParticipant {
        UIParticipant(participant: makeMockParticipant(id: "self", isRemote: false))
    }

    private func remote(_ id: String = "remote", screenshare: Bool = false) -> UIParticipant {
        UIParticipant(participant: makeMockParticipant(id: id, isScreenshare: screenshare))
    }

    @Test(
        "A camera-only pair uses the floating layout regardless of tile ordering or selected layout",
        arguments: [MeetingRoomLayout.grid, .activeSpeaker])
    func cameraPair(layout: MeetingRoomLayout) throws {
        for participants in [[local(), remote()], [remote(), local()]] {
            let content = MeetingRoomContent(participants: participants, layout: layout, activeSpeakerId: "self")
            let pair = try #require(content.oneToOneParticipants)
            #expect(pair.local.id == "self")
            #expect(pair.remote.id == "remote")
        }
    }

    @Test("Screen sharing restores the existing layout and removing it restores the one-to-one layout")
    func screenSharingTransition() {
        let cameraPair = [local(), remote()]
        #expect(OneToOneParticipants(participants: cameraPair) != nil)
        #expect(OneToOneParticipants(participants: cameraPair + [remote("share", screenshare: true)]) == nil)
        #expect(OneToOneParticipants(participants: [local(), remote("share", screenshare: true)]) == nil)
        #expect(OneToOneParticipants(participants: cameraPair) != nil)
    }

    @Test("Waiting alone, multiple remote participants and missing self-view keep the existing layout")
    func otherMeetings() {
        #expect(OneToOneParticipants(participants: []) == nil)
        #expect(OneToOneParticipants(participants: [local()]) == nil)
        #expect(OneToOneParticipants(participants: [remote(), remote("second")]) == nil)
        #expect(OneToOneParticipants(participants: [local(), remote(), remote("second")]) == nil)
    }

    @Test("Camera-off participants still use the same one-to-one layout")
    func cameraOff() {
        let participants = [
            UIParticipant(participant: makeMockParticipant(id: "self", isCameraEnabled: false, isRemote: false)),
            UIParticipant(participant: makeMockParticipant(id: "remote", isCameraEnabled: false)),
        ]
        #expect(OneToOneParticipants(participants: participants) != nil)
    }

    @Test("Dragging snaps to each nearest corner", arguments: FloatingSelfViewCorner.allCases)
    func snapping(corner: FloatingSelfViewCorner) {
        let geometry = FloatingSelfViewGeometry(container: CGSize(width: 390, height: 720), bottomInset: 64)
        #expect(geometry.nearestCorner(to: geometry.center(for: corner)) == corner)
    }

    @Test(
        "All corners remain within the content area and clear of controls after resizing",
        arguments: [
            CGSize(width: 390, height: 720), CGSize(width: 780, height: 320),
            CGSize(width: 1, height: 1), .zero,
        ])
    func boundedCorners(container: CGSize) {
        let geometry = FloatingSelfViewGeometry(container: container, bottomInset: 64)
        for corner in FloatingSelfViewCorner.allCases {
            let center = geometry.center(for: corner)
            let rect = CGRect(
                x: center.x - geometry.tileSize.width / 2,
                y: center.y - geometry.tileSize.height / 2,
                width: geometry.tileSize.width,
                height: geometry.tileSize.height)
            #expect(rect.minX >= 0)
            #expect(rect.minY >= 0)
            #expect(rect.maxX <= container.width + 0.001)
            #expect(rect.maxY <= container.height + 0.001)
            if container.height > 150 {
                #expect(rect.maxY <= container.height - 64)
                #expect(rect.minY >= 48 - 0.001)
            }
        }
    }

    @Test(
        "The composed one-to-one layout renders at the available portrait and landscape sizes",
        arguments: [CGSize(width: 390, height: 720), CGSize(width: 780, height: 320)])
    func rendersLayout(size: CGSize) throws {
        let content = MeetingRoomContent(
            participants: [local(), remote()], layout: .grid, activeSpeakerId: nil, selfViewBottomInset: 64
        )
        .frame(width: size.width, height: size.height)
        let renderer = ImageRenderer(content: content)
        let image = try #require(renderer.cgImage)
        #expect(image.width == Int(size.width))
        #expect(image.height == Int(size.height))
    }

    @Test("Dragging beyond the edges remains clamped and hiding controls preserves the chosen corner")
    func clampingAndControls() {
        let size = CGSize(width: 390, height: 720)
        let visible = FloatingSelfViewGeometry(container: size, bottomInset: 64)
        let hidden = FloatingSelfViewGeometry(container: size, bottomInset: 0)
        #expect(visible.clamped(CGPoint(x: -1000, y: -1000)) == visible.center(for: .topLeft))
        #expect(visible.clamped(CGPoint(x: 10000, y: 10000)) == visible.center(for: .bottomRight))
        #expect(hidden.center(for: .bottomRight).y > visible.center(for: .bottomRight).y)
        #expect(hidden.nearestCorner(to: hidden.center(for: .topLeft)) == .topLeft)
    }
}
