//
//  PicPreviewViewController.swift
//  EmojiCam
//
//  Created by Aditya Narayan on 6/27/17.
//
//

import UIKit

class PicPreviewViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var theImage: CIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(theImage, from: theImage.extent) else { return }
        let finalImage = UIImage(cgImage: cgImage)
        
        imageView.image = finalImage
    }

}
