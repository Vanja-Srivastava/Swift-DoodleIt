//
//  common.swift
//  PaintApp
//
//  Created by Vanja Srivastava on 7/22/20.
//  Copyright © 2020 Vanja Srivastava. All rights reserved.
//

import Foundation

/* used for declaring all the commonly used constants and structure values. */

/* constant declared for Key to be used for storing and reading from User defaults.*/
let drawingsArrayKey = "drawingsArrayKey"

/* Structure conforms to Codable as it is to encode and decode UIColor and to save and read it from USerDefaults */

struct Color : Codable {
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

    var uiColor : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(uiColor : UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}


/*
 * Structure for encapsulating touched points, color, and width of the drawing.
 * Structure conforms to Codable as it is to be encoded and decoded to save and read from USerDefaults.
 */
struct TouchPointsAndColor: Codable {
    var color: Color?
    var width: CGFloat?
    var opacity: CGFloat?
    var points: [CGPoint]?
    
    init(color: UIColor, points: [CGPoint]?) {
        self.color = Color.init(uiColor: color)
        self.points = points
    }
    
    enum CodingKeys: String, CodingKey {
        case color, width, opacity, points
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        width = CGFloat(try container.decode(Double.self, forKey: .width))
        opacity = CGFloat(try container.decode(Double.self, forKey: .opacity))
        points = try container.decode(Array<CGPoint>.self, forKey: .points)
        
        color = try container.decode(Color.self, forKey: .color)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(width, forKey: .width)
        try container.encode(opacity, forKey: .opacity)
        try container.encode(points, forKey: .points)
        try container.encode(color, forKey:.color)
    }
}

/*
* Structure for encapsulating touched points, id and image of the saved drawing.
* Structure conforms to Codable as it is to be encoded and decoded to save and read from USerDefaults.
*/

struct SavedDrawings:Codable {
    var id : String?
    var points : [TouchPointsAndColor]?
    var image: UIImage?
    
    init() {
        
    }
    init(id : String?, points : [TouchPointsAndColor]?, image: UIImage?) {
        self.id = id
        self.image = image
        self.points = points
    }
    enum CodingKeys: String, CodingKey {
        case id,image, points
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        points = try container.decode(Array<TouchPointsAndColor>.self, forKey: .points)
        let imageData = try container.decode(Data.self, forKey: .image)
        image = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(imageData) as? UIImage
        
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(points, forKey: .points)
        let imageData = try NSKeyedArchiver.archivedData(withRootObject: image ?? UIImage(systemName: "pencil.and.outline"), requiringSecureCoding: false)
        try container.encode(imageData, forKey: .image)
    }
}

