//
//  ViewController5.swift
//  Draw
//
//  Created by The YooGle on 06/11/22.
//

import UIKit

class ViewController5: UIViewController {
    
    let imageView = MySublayerImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

class MySublayerImageView: UIImageView {
    
    var currentTouchPosition: CGPoint?
    var drawingLayer: CALayer?
    
    var lineWidth: CGFloat = 3
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        currentTouchPosition = newTouchPoint
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        guard let previousTouchPoint = currentTouchPosition else { return }
        
        drawBezier(from: previousTouchPoint, to: newTouchPoint)
        currentTouchPosition = newTouchPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        flattenToImage()
        currentTouchPosition = nil
    }
    
    func setupDrawingLayerIfNeeded() {
        guard self.drawingLayer == nil else { return }
        
        let sublayer = CALayer()
        sublayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(sublayer)
        self.drawingLayer = sublayer
    }
    
    func flattenToImage() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        if let context = UIGraphicsGetCurrentContext() {
            if let image = self.image {
                image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            }
            
            drawingLayer?.render(in: context)
            
            let output = UIGraphicsGetImageFromCurrentImageContext()
            self.image = output
        }
        
        clearSublayers()
        UIGraphicsEndImageContext()
    }
    
    func drawBezier(from start: CGPoint, to end: CGPoint) {
        setupDrawingLayerIfNeeded()
        
        let line = CAShapeLayer()
        line.contentsScale = UIScreen.main.scale
        line.fillColor = UIColor.gray.cgColor
        line.opacity = 1
        line.lineWidth = lineWidth
        line.lineCap = .round
        line.strokeColor = UIColor.gray.cgColor
        
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        
        line.path = linePath.cgPath
        drawingLayer?.addSublayer(line)
        
        if let count = drawingLayer?.sublayers?.count, count > 400 {
            flattenToImage()
        }
    }
    
    func clearSublayers() {
        drawingLayer?.removeFromSuperlayer()
        drawingLayer = nil
    }
    
}
