//
//  CustomAnnotation.swift
//  runwithfriends
//
//  Created by xavier chia on 13/11/23.
//

import UIKit
import MapKit

// MARK: Custom classes to support emoji map annotations
class EmojiAnnotation: MKPointAnnotation {
    var emojiImage: UIImage
    var color: UIColor
    var identifier: String?
    
    init(emojiImage: UIImage, color: UIColor = .white) {
        self.emojiImage = emojiImage
        self.color = color
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
