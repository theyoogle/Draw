//
//  ViewController6.swift
//  Draw
//
//  Created by The YooGle on 06/11/22.
//

import UIKit

class ViewController6: UIViewController {
    
    let myView = MySublayerDrawingView()

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

class MySublayerDrawingView: UIView {
    
    var lineWidth: CGFloat = 3
    var drawingLayer: CAShapeLayer?
    
    var line = [CGPoint]() {
        didSet {
            checkIfTooManyPointsIn()
        }
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        
        let linePath = UIBezierPath()
        for (index, point) in line.enumerated() {
            if index == 0 {
                linePath.move(to: point)
            } else {
                linePath.addLine(to: point)
            }
        }
        
        // create new CAShaperLayer if not exist
        let drawingLayer = self.drawingLayer ?? CAShapeLayer()
        drawingLayer.contentsScale = UIScreen.main.scale
        drawingLayer.path = linePath.cgPath
        drawingLayer.opacity = 1
        drawingLayer.lineWidth = lineWidth
        drawingLayer.lineCap = .round
        drawingLayer.fillColor = UIColor.clear.cgColor
        drawingLayer.strokeColor = UIColor.gray.cgColor
        
        if self.drawingLayer == nil {
            self.drawingLayer = drawingLayer
            layer.addSublayer(drawingLayer)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        
        let lastTouchPoint: CGPoint = line.last ?? .zero
        line.append(newTouchPoint)
        
        let rect = calculateRectBetween(lastPoint: lastTouchPoint, newPoint: newTouchPoint)
        self.layer.setNeedsDisplay(rect)
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
    
    func checkIfTooManyPointsIn() {
        let maxPoints = 25
        if line.count > maxPoints {
            updateFlattenedLayer()
            
            // leave 2 points for no gap/sharp angles
            line.removeFirst(maxPoints - 2)
        }
    }
    
    func updateFlattenedLayer() {
        guard let drawingLayer = self.drawingLayer,
              let optionalDrawing = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                NSKeyedArchiver.archivedData(withRootObject: drawingLayer, requiringSecureCoding: false)
              ) as? CAShapeLayer else { return }
        
        self.layer.addSublayer(optionalDrawing)
    }
    
    func flattenImage() {
        updateFlattenedLayer()
        line.removeAll()
    }
    
    func emptyFlattenedLayers() {
        guard let sublayers = self.layer.sublayers else { return }
        for case let layer as CAShapeLayer in sublayers {
            layer.removeFromSuperlayer()
        }
    }
    
    func clear() {
        emptyFlattenedLayers()
        self.drawingLayer?.removeFromSuperlayer()
        self.drawingLayer = nil
        self.line.removeAll()
        self.layer.setNeedsDisplay()
    }
}
