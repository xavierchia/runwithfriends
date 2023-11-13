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
    var emojiImage: UIImage!
    
    init(emojiImage: UIImage!) {
        self.emojiImage = emojiImage
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
        glyphImage = (annotation as? EmojiAnnotation)?.emojiImage
        markerTintColor = .white
    }
}

class OriginalUIImage: UIImage {
    convenience init?(emojiString: String) {
        let image = emojiString.image(pointSize: 10)
        self.init(cgImage: image.cgImage!)
    }

    override func withRenderingMode(_ renderingMode: UIImage.RenderingMode) -> UIImage {
        return self
    }
}
