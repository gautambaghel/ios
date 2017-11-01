//
//  ImageViewController.swift
//  Supervision Search
//
//  Created by Gautam on 10/31/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit



class ImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultLabel: UILabel!
    
    var imageData: Data? = nil
    var imageView: UIImageView?
    var scrollView: UIScrollView? = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .cyan
        return v
    }()
    
    var ocr = CognitiveServices.sharedInstance.ocr
    
    
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image: UIImage = UIImage(data: imageData!)!
        
        // COGINITITON STUFF
        DispatchQueue.global(qos: .background).async {
            
            var text: String?
            // let imageData = UIImagePNGRepresentation(UIImage(named: "ocrDemo")!)!
            let requestObject: OCRRequestObject = (resource: self.imageData, language: .Automatic, detectOrientation: true)
            try! self.ocr.recognizeCharactersWithRequestObject(requestObject, completion: { (response) in
                if (response != nil){
                    text = self.ocr.extractStringFromDictionary(response!)
                    DispatchQueue.main.async {
                        self.resultLabel.text = text!
                    }
                }
            })
        }
        
        self.imageView = UIImageView(image: image)
        let imageFrame = CGRect(origin: CGPoint(x: 0,y :0),
                                size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
        self.imageView!.frame = imageFrame
        
        self.scrollView = UIScrollView(frame: self.view.bounds)
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

}
