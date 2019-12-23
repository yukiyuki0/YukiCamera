//
//  RoundButton.swift
//  YukiCamera
//
//  Created by Insu Byeon on 2019/12/23.
//  Copyright © 2019 Insu Byeon. All rights reserved.
//

// https://stackoverflow.com/questions/51701397/creating-a-thin-black-circle-unfilled-within-a-filled-white-circle-uibutton
import UIKit

internal extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

class RoundButton: UIButton {
    override func draw(_ rect: CGRect) {
        makeButtonImage()?.draw(at: CGPoint(x: 0, y: 0))
    }

    func makeButtonImage() -> UIImage? {
        let size = bounds.size

        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        defer {
            UIGraphicsEndImageContext()
        }
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }

        let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        // Want to "over fill" the image area, so the mask can be applied
        // to the entire image
        let radius = min(size.width / 2.0, size.height / 2.0)

        let innerRadius = radius * 0.75
        let innerCircle = UIBezierPath(arcCenter: center,
                                       radius: innerRadius,
                                       startAngle: CGFloat(0.0).degreesToRadians,
                                       endAngle: CGFloat(360.0).degreesToRadians,
                                       clockwise: true)
        // The color doesn't matter, only it's alpha level
        UIColor.red.setStroke()
        innerCircle.lineWidth = 4.0
        innerCircle.stroke(with: .normal, alpha: 1.0)

        let circle = UIBezierPath(arcCenter: center,
                                  radius: radius,
                                  startAngle: CGFloat(0.0).degreesToRadians,
                                  endAngle: CGFloat(360.0).degreesToRadians,
                                  clockwise: true)
        UIColor.clear.setFill()
        ctx.fill(bounds)

        UIColor.white.setFill()
        circle.fill(with: .sourceOut, alpha: 1.0)

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
