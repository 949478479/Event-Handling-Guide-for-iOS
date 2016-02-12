//
//  ViewController.swift
//  MonkeyPinch
//
//  Created by 从今以后 on 15/12/20.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit
import AVFoundation.AVAudioPlayer

final class ViewController: UIViewController {

    @IBOutlet var monkeyTapGR: UITapGestureRecognizer!
    @IBOutlet var monkeyPanGR: UIPanGestureRecognizer!

    @IBOutlet var bananaTapGR: UITapGestureRecognizer!
    @IBOutlet var bananaPanGR: UIPanGestureRecognizer!

    lazy var chompPlayer: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("chomp.caf", withExtension: nil)!
        let player = try! AVAudioPlayer(contentsOfURL: url)
        return player
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        monkeyTapGR.requireGestureRecognizerToFail(monkeyPanGR)
        bananaTapGR.requireGestureRecognizerToFail(bananaPanGR)
    }
}

typealias GestureRecognizerHandler = ViewController
extension GestureRecognizerHandler {

    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {

        let translation = recognizer.translationInView(view)
        recognizer.view?.center.offsetInPlace(dx: translation.x, dy: translation.y)
        recognizer.setTranslation(CGPointZero, inView: view)

        if recognizer.state == .Ended {

            let velocity = recognizer.velocityInView(view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200

            let slideFactor = 0.1 * slideMultiplier

            var finalPoint = recognizer.view!.center
                .offsetBy(dx: velocity.x * slideFactor, dy: velocity.y * slideFactor)

            finalPoint.x = min(max(finalPoint.x, 0), view.bounds.width)
            finalPoint.y = min(max(finalPoint.y, 0), view.bounds.height)

            UIView.animateWithDuration(Double(slideFactor * 2),
                delay: 0,
                options: .CurveEaseOut,
                animations: { recognizer.view!.center = finalPoint },
                completion: nil)
        }
    }

    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer) {
        recognizer.view?.transform.scaleInPlace(sx: recognizer.scale, sy: recognizer.scale)
        recognizer.scale = 1.0
    }

    @IBAction func handleRotate(recognizer: UIRotationGestureRecognizer) {
        recognizer.view?.transform.rotateInPlace(angle: recognizer.rotation)
        recognizer.rotation = 0.0
    }

    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        chompPlayer.play()
    }
}

typealias GestureRecognizerDelegate = ViewController
extension GestureRecognizerDelegate: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
        return true
    }
}

extension CGPoint {

    func offsetBy(dx dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }

    mutating func offsetInPlace(dx dx: CGFloat, dy: CGFloat) {
        self.x += dx
        self.y += dy
    }
}

extension CGAffineTransform {

    mutating func scaleInPlace(sx sx: CGFloat, sy: CGFloat) {
        self = CGAffineTransformScale(self, sx, sy)
    }

    mutating func rotateInPlace(angle angle: CGFloat) {
        self = CGAffineTransformRotate(self, angle)
    }
}
