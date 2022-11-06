//
//  ViewController3.swift
//  Draw
//
//  Created by The YooGle on 06/11/22.
//

import UIKit

class ViewController3: UIViewController {
    
    let myView = MyRectDrawingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myView)
        
        NSLayoutConstraint.activate([
            myView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            myView.topAnchor.constraint(equalTo: view.topAnchor),
            myView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

class MyRectDrawingView: UIView {
    
    var lines = [[CGPoint]]()
    var lineWidth: CGFloat = 5
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        
        lines.forEach { (line) in
            for (index, point) in line.enumerated() {
                if index == 0 {
                    context.move(to: point)
                } else {
                    context.addLine(to: point)
                }
            }
        }
        context.strokePath()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append([CGPoint]())
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        
        var lastTouchPoint: CGPoint = .zero
        
        if let lastIndex = lines.indices.last {
            if let lastPoint = lines[lastIndex].last {
                lastTouchPoint = lastPoint
            }
            
            lines[lastIndex].append(newTouchPoint)
        }
        
        let rect = calculateRectBetween(lastPoint: lastTouchPoint, newPoint: newTouchPoint)
        setNeedsDisplay(rect)
    }
    
    func calculateRectBetween(lastPoint: CGPoint, newPoint: CGPoint) -> CGRect {
        let originX = min(lastPoint.x, newPoint.x) - (lineWidth/2)
        let originY = min(lastPoint.y, newPoint.y) - (lineWidth/2)
        
        let maxX = max(lastPoint.x, newPoint.x) + (lineWidth/2)
        let maxY = max(lastPoint.y, newPoint.y) + (lineWidth/2)
        
        let width = maxX - originX
        let height = maxY - originY
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
}
