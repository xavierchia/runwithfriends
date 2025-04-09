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
    var titleString: String {
        didSet {
            title = titleString
        }
    }
    var subtitleString: String {
        didSet {
            subtitle = subtitleString
        }
    }
    var emojiImage: UIImage
    var color: UIColor = .white
    var identifier: String = "" {
        didSet {
            self.color = identifier == "user" ? .lightAccent : .white
        }
    }
    
    init(titleString: String = "",
         subtitleString: String = "",
         emojiImage: UIImage,
         identifier: String) {
        self.titleString = titleString
        self.subtitleString = subtitleString
        self.emojiImage = emojiImage
        self.identifier = identifier
        
        super.init()
        
        self.color = identifier == "user" ? .lightAccent : .white
        
        if identifier == "user" || identifier == "other" {
            title = titleString
            subtitle = subtitleString
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

class OriginalUIImage: UIImage, @unchecked Sendable {
    convenience init(emojiString: String) {
        let image = emojiString.image(pointSize: 30)
        self.init(cgImage: image.cgImage!)
    }

    override func withRenderingMode(_ renderingMode: UIImage.RenderingMode) -> UIImage {
        return self
    }
}
