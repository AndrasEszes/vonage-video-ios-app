//
//  Created by Vonage on 14/7/26.
//

import AVKit
import Foundation
import Testing
import UIKit

@testable import VERAVonage

@Suite("PictureInPictureController tests")
@MainActor
struct PictureInPictureControllerTests {

    private struct StubError: Swift.Error {}

    private func makeAVController() -> AVPictureInPictureController {
        let contentViewController = AVPictureInPictureVideoCallViewController()
        let source = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: UIView(),
            contentViewController: contentViewController)
        return AVPictureInPictureController(contentSource: source)
    }

    @Test("Initial state is not configured and not in PiP")
    func initialState() {
        let sut = PictureInPictureController()
        #expect(sut.isConfigured == false)
        #expect(sut.isInPictureInPicture == false)
    }

    // PiP is unsupported on the simulator, so `configure` can't produce a live controller there;
    // this exercises the configure path for coverage.
    @Test("configure and re-configure run without crashing")
    func configureRuns() {
        let sut = PictureInPictureController()
        sut.configure(with: UIView())
        sut.configure(with: UIView())  // re-anchor path (tearDown + rebuild)
        #expect(sut.isInPictureInPicture == false)
    }

    @Test("tearDown clears PiP state")
    func tearDownClears() {
        let sut = PictureInPictureController()
        sut.configure(with: UIView())
        sut.tearDown()
        #expect(sut.isConfigured == false)
        #expect(sut.isInPictureInPicture == false)
    }

    @Test("tearDown is safe when not configured")
    func tearDownIdempotent() {
        let sut = PictureInPictureController()
        sut.tearDown()
        #expect(sut.isConfigured == false)
    }

    @Test("attachFeed exercises the wiring path")
    func attachFeedRuns() {
        let sut = PictureInPictureController()
        sut.configure(with: UIView())
        let renderer = PictureInPictureVideoRenderer()

        sut.attachFeed(to: renderer)  // wires when configured; no-op otherwise (simulator)
    }

    @Test("attachFeed is a no-op when not configured")
    func attachFeedWhenNotConfigured() {
        let sut = PictureInPictureController()
        let renderer = PictureInPictureVideoRenderer()

        sut.attachFeed(to: renderer)

        #expect(renderer.pipBufferDisplayLayer == nil)
    }

    @Test("start and stop are safe to call")
    func startStopSafe() {
        let sut = PictureInPictureController()
        sut.configure(with: UIView())
        sut.startPictureInPicture()
        sut.stopPictureInPicture()
    }

    @Test("supported/canStart flags are readable")
    func flags() {
        let sut = PictureInPictureController()
        _ = sut.isPictureInPictureSupported
        _ = sut.canStartPictureInPicture
    }

    @Test("Callbacks from an unrelated controller cannot start or stop this lifetime")
    func unrelatedControllerCallbacksAreIgnored() {
        let sut = PictureInPictureController()
        let controller = makeAVController()
        var callbacks = 0
        sut.onPictureInPictureStateDidStart = { callbacks += 1 }
        sut.onPictureInPictureStateDidStop = { callbacks += 1 }
        sut.onPictureInPictureFailed = { _ in callbacks += 1 }

        sut.pictureInPictureControllerWillStartPictureInPicture(controller)
        sut.pictureInPictureControllerDidStopPictureInPicture(controller)
        sut.pictureInPictureController(controller, failedToStartPictureInPictureWithError: StubError())

        #expect(!sut.isInPictureInPicture)
        #expect(callbacks == 0)
    }
}
