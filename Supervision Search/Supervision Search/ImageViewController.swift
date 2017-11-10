//
//  ImageViewController.swift
//  Supervision Search
//
//  Created by Gautam on 10/31/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit



class ImageViewController: UIViewController, UIScrollViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var imageData: Data? = nil
    
    var imageView: UIImageView? = {
        let v = UIImageView()
        // v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.black
        return v
    }()
    
    var scrollView: UIScrollView? = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.black
        return v
    }()
    
    var ocr = CognitiveServices.sharedInstance.ocr
    var image: UIImage?
    var highlightedImage: UIImage?
    var isHighlighted: Bool = false
    
    
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        image = UIImage(data: imageData!)!
        
        // COGINITITON STUFF
        DispatchQueue.global(qos: .background).async {
            
            // let imageData = UIImagePNGRepresentation(UIImage(named: "ocrDemo")!)!
            let requestObject: OCRRequestObject = (resource: self.imageData, language: .Automatic, detectOrientation: true)
            try! self.ocr.recognizeCharactersWithRequestObject(requestObject, completion: { (response) in
                if (response != nil){
                    DispatchQueue.main.async {
                        let _ = self.ocr.extractStringFromDictionary(response!)
                        self.orientImage()
                    }
                }
            })
        }
        
        setupImageInImageview()
    }
    
    func setupImageInImageview() {
        
        //remove the earlier view
        self.scrollView?.removeFromSuperview()
        
        self.imageView!.image = image
        let imageFrame = CGRect(origin: CGPoint(x: 0,y :0),
                                size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
        self.imageView!.frame = imageFrame
        
        self.scrollView?.frame = self.view.bounds
        //adding imageview as a subview of scroll view
        self.scrollView?.addSubview(self.imageView!)
        // content size of the scroll view is the size of the image
        self.scrollView?.contentSize = (self.imageView?.bounds.size)!
        //scroll view is the subview of main view
        self.scrollView?.delegate = self
        self.scrollView?.minimumZoomScale = 1.0
        self.scrollView?.maximumZoomScale = 5.0
        
        mainView.addSubview(self.scrollView!)
        
        self.scrollView?.isUserInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.singleTapDetected))
        singleTap.numberOfTapsRequired = 1
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.doubleTapDetected))
        doubleTap.numberOfTapsRequired = 2
        
        self.scrollView?.addGestureRecognizer(singleTap)
        self.scrollView?.addGestureRecognizer(doubleTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func singleTapDetected(recognizer: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    func doubleTapDetected(recognizer: UITapGestureRecognizer) {
        if scrollView?.zoomScale == 1 {
            scrollView?.zoom(to: zoomRectForScale(scale: (scrollView?.maximumZoomScale)!, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollView?.setZoomScale(1, animated: true)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = (imageView?.frame.size.height)! / scale
        zoomRect.size.width  = (imageView?.frame.size.width)!  / scale
        let newCenter = imageView?.convert(center, from: scrollView)
        zoomRect.origin.x = (newCenter?.x)! - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = (newCenter?.y)! - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    @IBAction func micPressed(_ sender: UIButton) {
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Each letter added
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let word = self.ocr.wordCoordinates[searchBar.text!] {
            
            let wordRect = word.characters.split{$0 == ","}.map(String.init)
            let x = Double(wordRect[0])!
            let y = Double(wordRect[1])!
            let width = Double(wordRect[2])!
            let height = Double(wordRect[3])!
            let rect = CGRect(x: x, y: y, width: width, height: height)
        
            highlightedImage = drawHighlightedImage(rect: rect, image: image!)
            self.imageView!.image = highlightedImage
            startBlinking()
        }
        
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    func orientImage() {
        
        let orientation = self.ocr.orientation
        var angle: Float = 0
        switch (orientation) {
           case "Down":
            angle = 180
           case "Left":
            angle = 90
           case "Right":
            angle = 270
           default: break
        }
        
        angle = angle - self.ocr.textAngle
        image = rotateImage(image: image!, angle: angle)
        self.imageView?.image = image
    }
    
    func radians(_ s1: Float) -> Float {
        return s1 * Float(M_PI/180)
    }
    
    func rotateImage(image: UIImage, angle: Float) -> UIImage {
       
        // TODO: Change the rotation context from 0,0 to center of the image
        let cx = image.size.width / 2
        let cy = image.size.height / 2
        
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        var transform = CGAffineTransform.init(translationX: cx , y: cy)
        transform = transform.rotated(by: CGFloat(radians(angle)))
        transform = transform.translatedBy(x: -cx, y: -cy)
        context!.concatenate(transform)
        image.draw(at: .zero)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage!
    }
    
    func startBlinking() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            if self.isHighlighted {
                self.imageView!.image = self.image
                self.isHighlighted = false
            } else {
                self.imageView!.image = self.highlightedImage
                self.isHighlighted = true
            }
            self.startBlinking()
        })
        
    }
    
    func drawHighlightedImage(rect: CGRect, image: UIImage) -> UIImage {
        
        // begin a graphics context of sufficient size
        UIGraphicsBeginImageContext(image.size)
        
        // draw original image into the context
        image.draw(at: .zero)
        
        // get the context for CoreGraphics
        let context = UIGraphicsGetCurrentContext()
        
        // set stroking width and color of the context
        context!.setLineWidth(15.0)
        context!.setStrokeColor(UIColor.green.cgColor)
        
        // Draw rect
        context!.stroke(rect)
        
        // get the image from the graphics context
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the graphics context 
        UIGraphicsEndImageContext()
        
        return (resultImage)!
    }
    
}
