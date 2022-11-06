//
//  ViewController4.swift
//  Draw
//
//  Created by The YooGle on 06/11/22.
//

import UIKit

class ViewController4: UIViewController {
    
    let myView = MyFlatDrawingView()

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

class MyFlatDrawingView: UIView {
    
    var flattenedImage: UIImage?
    
    var line = [CGPoint]() {
        didSet {
            checkIfTooManyPointsIn(&line)
        }
    }
    var lineWidth: CGFloat = 3
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if let image = flattenedImage {
            image.draw(in: self.bounds)
        }
        
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        
        for (index, point) in line.enumerated() {
            if index == 0 {
                context.move(to: point)
            } else {
                context.addLine(to: point)
            }
        }
        context.strokePath()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        
        let lastTouchPoint: CGPoint = line.last ?? .zero
        line.append(newTouchPoint)
        
        let rect = calculateRectBetween(lastPoint: lastTouchPoint, newPoint: newTouchPoint)
        setNeedsDisplay(rect)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        flattenImage()
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
    
    func checkIfTooManyPointsIn(_ line: inout [CGPoint]) {
        let maxPoints = 200
        if line.count > maxPoints {
            flattenedImage = self.getImageRepresentation()
            
            // leave one point for no gap
            line.removeFirst(maxPoints - 1)
        }
    }
    
    func flattenImage() {
        flattenedImage = self.getImageRepresentation()
        line.removeAll()
    }
    
    func getImageRepresentation() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        
        return nil
    }
    
}
