//
//  SpirographGenerator.swift
//  RxPlayground
//
//  Created by Joshua Homann on 4/22/19.
//  Copyright © 2019 com.josh. All rights reserved.
//
import UIKit
import RxSwift

// Shamelessly stolen and updated from: https://ericasadun.com/2014/06/23/swift-spiroswiftograph/
struct SpirographGenerator : IteratorProtocol {

    var pointOffset, dTheta, dR, minorRadius, majorRadius : CGFloat
    var theta: CGFloat = 0.0
    typealias Element = CGPoint

    init(majorRadius : CGFloat, minorRadius : CGFloat, pointOffset : CGFloat, samples : CGFloat)
    {
        self.pointOffset = pointOffset
        self.dTheta = 2 * CGFloat.pi / samples
        self.majorRadius = majorRadius
        self.minorRadius = minorRadius
        self.dR = majorRadius - minorRadius
    }

    mutating func next() -> CGPoint? {
        let xT = dR * cos(theta) + pointOffset * cos(dR * theta / minorRadius)
        let yT = dR * sin(theta) + pointOffset * sin(dR * theta / minorRadius)
        theta = theta + dTheta
        return CGPoint(x: CGFloat(xT), y: CGFloat(yT))
    }
}

extension UIGraphicsImageRenderer {
    func image(from spirographGenerator: SpirographGenerator, dimension: CGFloat, color: UIColor = .black) -> UIImage {
        var spirographGenerator = spirographGenerator
        return image { context in
            color.setStroke()
            let points = (0..<500).compactMap { _ in
                spirographGenerator
                    .next()
                    .map { CGPoint(x: $0.x+dimension/2, y: $0.y+dimension/2) }
            }
            let path = UIBezierPath()
            points
                .prefix(1)
                .forEach { path.move(to: $0) }
            points
                .dropFirst()
                .reduce(into: path) { $0.addLine(to: $1) }
                .stroke()
        }
    }
}
