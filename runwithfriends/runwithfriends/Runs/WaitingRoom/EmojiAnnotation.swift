//
//  CustomAnnotation.swift
//  runwithfriends
//
//  Created by xavier chia on 13/11/23.
//

import UIKit
import MapKit
import SharedCode

// MARK: Custom classes to support emoji map annotations
class EmojiAnnotation: MKPointAnnotation {
    let username: String
    let weekSteps: Int
    let daySteps: Int
    var emojiImage: UIImage
    var color: UIColor = .white
    var identifier: String = ""
    
    init(username: String = "",
         emojiImage: UIImage,
         identifier: String,
         daySteps: Int = 0,
         weekSteps: Int = 0) {
        self.username = username
        self.emojiImage = emojiImage
        self.identifier = identifier
        self.daySteps = daySteps
        self.weekSteps = weekSteps
        
        super.init()
        
        self.color = identifier == "user" ? .lightAccent : .white
        
        if identifier == "user" || identifier == "other" {
            let stepString = weekSteps.valueKM
            title = "\(username): \(stepString)"
            let todaySteps = daySteps.valueKM
            subtitle = "Today: \(todaySteps)"
        }
        
        if identifier == "user",
           let isUserIntroTapped = PeaDefaults.shared?.bool(forKey: UserDefaultsKey.isUserIntroTapped),
           isUserIntroTapped == false {
            title = title?.appending(" (Click me!)")
        }
    }
}

class EmojiAnnotationView: MKMarkerAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = true
        update(for: annotation)
    }

    override var annotation: MKAnnotation? { didSet { update(for: annotation) } }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func update(for annotation: MKAnnotation?) {
        if let emojiAnnotation = annotation as? EmojiAnnotation {
            glyphImage = emojiAnnotation.emojiImage
            markerTintColor = emojiAnnotation.color
            self.displayPriority = .required
            
            if emojiAnnotation.identifier == "user" {
                self.layer.anchorPointZ = 0
            } else {
                self.layer.anchorPointZ = 10
            }
        }
    }
}

class OriginalUIImage: UIImage {
    convenience init(emojiString: String) {
        let image = emojiString.image(pointSize: 30)
        self.init(cgImage: image.cgImage!)
    }

    override func withRenderingMode(_ renderingMode: UIImage.RenderingMode) -> UIImage {
        return self
    }
}
