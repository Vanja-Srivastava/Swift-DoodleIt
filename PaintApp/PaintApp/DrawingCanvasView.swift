//
//  DrawingCanvasView.swift
//  PaintApp
//
//  Created by Vanja Srivastava on 7/20/20.
//  Copyright © 2020 Vanja Srivastava. All rights reserved.
//

import UIKit

/*
 * class for the drawing view.
 * It has methods and poroperties related to drawing.
 */
class DrawingCanvasView: UIView {

    //MARK: instance Variables
    
    /* variable for array of touched points*/
    var touchedPoints = [TouchPointsAndColor]()
    
    /* variable for representing width of the pen stroke. */
    var strokeWidth: CGFloat = 1.0
    
    /* variable for representing width of the eraser. */
    var eraseWidth: CGFloat = 1.0
    
    /* variable for representing pen stroke color. */
    var strokeColor: UIColor = .black
    
    /* variable for representing drawing opacity. */
    var strokeOpacity: CGFloat = 1.0
    
    /* variable to be used to check whether eraser is selected*/
    var isErasing = false
    
    
    //MARK: class methods
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        for touchedPoint  in touchedPoints {
            for (i, p) in (touchedPoint.points?.enumerated())! {
                if i == 0 {
                    context.move(to: p)
                } else {
                    context.addLine(to: p)
                }
                context.setStrokeColor(touchedPoint.color?.uiColor.withAlphaComponent(touchedPoint.opacity ?? 1.0).cgColor ?? UIColor.black.cgColor)
                context.setLineWidth(touchedPoint.width ?? 1.0)
            }
            context.setLineCap(.round)
            context.strokePath()
        }
        
    }
    
    /* method called when user starts to touch the screen to draw */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        touchedPoints.append(TouchPointsAndColor(color: UIColor(), points: [CGPoint]()))
    }
    
    /* method called when user starts to move on screen to draw */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.location(in: nil) else {
            return
        }
        
        guard var lastPoint = touchedPoints.popLast() else {return}
        lastPoint.points?.append(touch)
        
        lastPoint.color = self.isErasing ? Color.init(uiColor: UIColor.white) : Color.init(uiColor: strokeColor)
        lastPoint.width = self.isErasing ? eraseWidth : strokeWidth
        lastPoint.opacity = strokeOpacity
        touchedPoints.append(lastPoint)
        setNeedsDisplay()
    }
    
    /* method called when user clicks clear screen or reset button. This methods clears the screen.
     */
    func clearScreen() {
        touchedPoints.removeAll()
        setNeedsDisplay()
    }
    
    /* method called to redraw the points reading a saved drawing. This methods draws back the points on the drawing screen.
    */
    func redraw(points: [TouchPointsAndColor]) {
        touchedPoints = points
        setNeedsDisplay()
        
    }
    
    /* method is called when undo move button is pressed */
    func undoMove() {
        if touchedPoints.count > 0 {
            touchedPoints.removeLast()
            setNeedsDisplay()
        }
    }
    
}
