//
//  AllDrawingsController.swift
//  PaintApp
//
//  Created by Vanja Srivastava on 7/22/20.
//  Copyright © 2020 Vanja Srivastava. All rights reserved.
//

import Foundation

/*
 * Class for the root view controller.
 * This class presents the saved drawings inside a collection view.
 */

class AllDrawingsController: UICollectionViewController {
    
    //MARK: IBOutlets for UI Elements
    
    /* outlet variable for collection View */
    @IBOutlet var collectionview: UICollectionView!
    
    
    // MARK: instance variables
    
    /* variable for saving stored drawings in array*/
    var storedDrawings: [SavedDrawings] = []
    
    /* variables for setting view layout in collection view */
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let itemsPerRow: CGFloat = 4
    
    
    //MARK: class methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.tertiarySystemGroupedBackground
        collectionview.delegate = self
        collectionview.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /* reading user defaults to check if any drawings are saved. */
        /* If yes, then will show those saved drawings in the collection view */
        
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: drawingsArrayKey) as? Data {
            let decoder = JSONDecoder()
            if let array = try? decoder.decode([SavedDrawings].self, from: data){
                self.storedDrawings = array
            }
        }
        collectionView.reloadData()
    }
    
    //MARK: IBAction for UIButton
    
    /* Action method for start New drawing button click */
    @IBAction func onCLickNewDrawingButton(_ sender: Any) {
        let uuid = UUID().uuidString
        /* initializing storyboard */
        let storyboard = UIStoryboard(name: "Main 2", bundle: nil)
        
        /* Initializing drawing view controller */
        if let vc = storyboard.instantiateViewController(withIdentifier: "Drawingboard") as? DrawingViewController {
            vc.currentDrawing.id = uuid
            self.navigationController!.pushViewController(vc, animated: true)
        }
        
    }
    
    //MARK: Delegate methods for collection View
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

   
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.storedDrawings.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /* initalizing collection view cell */
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        /* showing the saved image of the drawaings made by user previously, in collection view cell */
        let imageview = cell.viewWithTag(1000) as? UIImageView
        imageview?.image  = self.storedDrawings[indexPath.row].image
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /* initializing storyboard */
        let storyboard = UIStoryboard(name: "Main 2", bundle: nil)
        
        /* Initializing drawing view controller */
        if let vc = storyboard.instantiateViewController(withIdentifier: "Drawingboard") as? DrawingViewController {
            vc.currentDrawing = self.storedDrawings[indexPath.row]
            self.navigationController!.pushViewController(vc, animated: true)
        }
        
    }
}

// MARK: - Collection View Flow Layout Delegate

extension AllDrawingsController : UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}






