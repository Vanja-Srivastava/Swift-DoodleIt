//
//  DrawingViewController.swift
//  PaintApp
//
//  Created by Vanja Srivastava on 7/20/20.
//  Copyright © 2020 Vanja Srivastava. All rights reserved.
//

import UIKit

/*
 * This class presents the drwaing area with some oen and eraser and other user options to draw on the screen.
 * it has methods for handling drawing,erasing on screen and saving the drawn file
 
 */

class DrawingViewController: UIViewController {
    
    // MARK: IBOutlets for UI elements
    
    /* outlet variable for drawing view (user can draw in this area) */
    @IBOutlet weak var drawingview: DrawingCanvasView!
    
    /* outlet variable for view with options to edit the drawing */
    @IBOutlet weak var optionsView: UIView!
    
    /* outlet variable for button which shows more options such as color picker, brush width etc.
     */
    @IBOutlet weak var optionsButton: UIButton!
    
    /* outlet variable for slider which controls thickness of the eraser */
    @IBOutlet weak var eraserWidthSlider: UISlider!
    
    /* outlet variable for slider which controls thickness of the bursh */
    @IBOutlet weak var widthSlider: UISlider!
    
    /* outlet variable for slider which controls opacity of the pen/brush */
    @IBOutlet weak var opacitySlider: UISlider!
    
    /* outlet variable for slider which controls the color picker view */
    @IBOutlet weak var colorPickerView: UIView!
    
    
    // MARK: instance variables
    
    /* variable for maximum height of the options view */
    var kHeight: CGFloat = 420
    
    /* variable to decalre aniamtion time */
    var animationTime = 0.35
    
    /* variable to keep the count of recent color used */
    var recentColorCounter = 1
    
    /* array variable to hold the 4 most recent colors used by user */
    var recentColors :[UIColor] = [UIColor.black]
    
    /* variable that represents the current drawing drawn by user */
    var currentDrawing: SavedDrawings = SavedDrawings()
    
    
    
    // MARK: class methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawingview.strokeWidth = 5
        drawingview.eraseWidth = 5
        optionsView.transform = CGAffineTransform(translationX: 0, y: self.kHeight)
        
        let pickerView = RSColorPickerView.init(frame: CGRect(x: 20.0, y: 10.0, width: 260.0, height: 260.0))
        pickerView.cropToCircle = true
        pickerView.delegate = self
        colorPickerView.addSubview(pickerView)
        
        /* adding two rightBarButtonItems to the navigation Bar */
        let saveButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(self.onClickSave(sender:)))
        
        let shareButton = UIBarButtonItem.init(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(self.onClickShare(sender:)))
        self.navigationItem.rightBarButtonItems = [saveButton, shareButton]
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /* reading saved points from the drawing and loading it to the canvas */
        if ((self.currentDrawing.image) != nil) {
            self.drawingview.redraw(points: self.currentDrawing.points ?? [])
        }
    }

    // MARK: action methods for Button
    
    /* Action method for save button click. */
    @objc func onClickSave(sender: UIBarButtonItem) {
        // take screen shot of the drawing made by user and make a image.
        let image = drawingview.clickScreenshot()
        
         
        let defaults = UserDefaults.standard
        var toBeSaved: [SavedDrawings] = []
        
        // reading from user defaults to know if the there are stored drawings.
        // if yes, then check if the current drawing is already saved before and has been edited again
        // if yes, then delete the saved drawing
        // save it again with new edited points by user.
        if let data = defaults.object(forKey: drawingsArrayKey) as? Data {
            let decoder = JSONDecoder()
            if var array = try? decoder.decode([SavedDrawings].self, from: data){
                if self.currentDrawing.image != nil {
                    let index = array.firstIndex{$0.id  == self.currentDrawing.id }
                    if let position = index {
                        array.remove(at: position)
                    }
                }
                toBeSaved = array
            }
        }
        let points = self.drawingview.touchedPoints
        self.currentDrawing.image = image
        self.currentDrawing.points = points
        print("Original array",toBeSaved.count)
        
        toBeSaved.append(self.currentDrawing)
        
        print("After append",toBeSaved.count)
        
        // encoding the drawing to be saved in userdefaults
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(toBeSaved) {
            defaults.set(encoded,forKey: drawingsArrayKey)
            defaults.synchronize()
            // this shows alert that the drawing has been saved.
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    /* Action method for share button. Shares the image of the drawing */
    @objc func onClickShare(sender: UIBarButtonItem) {
        let image = drawingview.clickScreenshot()
        let activity = UIActivityViewController(activityItems: [image],applicationActivities: nil)
        present(activity, animated: true)
    
    }

    // MARK: IBActions for UI buttons

    /* Action method for Recent colors button click. this method changes the colro of the pen / brush with it's color */
    @IBAction func onClickRecentColorButton(_ sender: Any) {
        let button = sender as! UIButton
        self.drawingview.strokeColor = button.backgroundColor ?? UIColor.black
    }
    
    /* Action method for Pencil button click. If selected or clicked once user will be able to draw on screen. */
    @IBAction func onClickPencil(_ sender: Any) {
        self.drawingview.isErasing = false
        self.drawingview.strokeWidth = 5
    }
    
    /* Action method for Eraser button click. if selected  or clicked once user will be able to erase the drawing.*/
    @IBAction func onClickEraseDraw(_ sender: Any) {
        self.drawingview.isErasing = true
        self.drawingview.eraseWidth = 5
    }

    /* Action method for Undo button click. This method undo the last move made by user*/
    @IBAction func onClickUndo(_ sender: Any) {
        drawingview.undoMove()
    }
    
    /* Action method for Clear button click. Method clears the whole drwaing view */
    @IBAction func onClickClear(_ sender: Any) {
        drawingview.clearScreen()
    }

    /* Action method for show more options button click. Method shows color picker view and other drawing options to the user. */
    @IBAction func onClickHideShowFeatureView(_ sender: UIButton) {
        if sender.isSelected {
            UIView.animate(withDuration: animationTime) {
                sender.isSelected = false
                self.optionsButton.setBackgroundImage(UIImage(systemName: "arrowtriangle.down.circle"), for: .normal)
                self.optionsView.backgroundColor = UIColor.clear
                self.optionsView.transform = CGAffineTransform(translationX: 0, y: self.kHeight)
            }
        } else {
            UIView.animate(withDuration: animationTime) {
                sender.isSelected = true
                self.optionsButton.setBackgroundImage(UIImage(systemName: "arrowtriangle.up.circle"), for: .normal)
                self.optionsView.transform = CGAffineTransform.identity
                self.optionsView.backgroundColor = UIColor.systemGray5
                
            }
        }
    }
    
    /* Action method to adjust Brush width slider changed*/
    @IBAction func onClickBrushWidth(_ sender: UISlider) {
        drawingview.strokeWidth = CGFloat(sender.value)
    }

    /* Action method to adjust opacticy slider changed*/
    @IBAction func onClickOpacity(_ sender: UISlider) {
        drawingview.strokeOpacity = CGFloat(sender.value)
        
    }

    /* Action method to adjust eraser width slider changed*/
    @IBAction func onClickEraserSlider(_ sender: UISlider) {
        drawingview.eraseWidth = CGFloat(sender.value)
    }
}

// MARK: extension for delegate methods of color picker
extension DrawingViewController: RSColorPickerViewDelegate {
    // method to be called if any color selection has been made by user in the color picker view.
    func colorPickerDidChangeSelection(_ colorPicker: RSColorPickerView!) {
        let color : UIColor = colorPicker.selectionColor
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a : CGFloat = 0
        colorPicker.selectionColor.getRed(&r, green: &g, blue: &b, alpha: &a)
         
        // recent color is 1 becasue black is already added as the first recent color.
        if recentColorCounter == 1 {
            recentColorCounter = 2
            return
        }
        
        // recent color array can only hold maximum of 4 colors. So reinitalizing the value
        // once it becomes more than 4
        if recentColorCounter >= 5 {
            recentColorCounter = 1
        }
        
        /* if the selected color in the picker view is already in the recent color array, it wont be added again in the array. */
        if (self.recentColors.contains(color) == false) {
            let button = self.optionsView.viewWithTag(recentColorCounter) as? UIButton
            recentColorCounter += 1
            button?.layer.cornerRadius = 3
            button?.backgroundColor = color
            self.drawingview.strokeColor = color
            self.recentColors.append(color)
            
        }
        self.drawingview.strokeColor = color
    }
}

//MARK: UIVIew extension for taking screenshot
extension UIView {
    
    func clickScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}



