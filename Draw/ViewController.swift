//
//  ViewController.swift
//  Draw
//
//  Created by The YooGle on 06/11/22.
//

import UIKit

class ViewController: UIViewController {
    
    let imageView = MyImageDrawingView()

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

class MyImageDrawingView: UIImageView {
    
    var currentTouchPosition: CGPoint?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        currentTouchPosition = newTouchPoint
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        guard let previousTouchPoint = currentTouchPosition else  { return }
        
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        image = renderer.image { ctx in
            image?.draw(in: bounds)
            UIColor.red.setStroke()
            ctx.cgContext.setLineCap(.round)
            ctx.cgContext.setLineWidth(5)
            
            ctx.cgContext.move(to: previousTouchPoint)
            ctx.cgContext.addLine(to: newTouchPoint)
            ctx.cgContext.strokePath()
        }
        
        currentTouchPosition = newTouchPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentTouchPosition = nil
    }
    
}
