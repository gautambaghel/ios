//
//  ImageViewController.swift
//  Supervision Search
//
//  Created by Gautam on 10/31/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit
import AVFoundation

class ImageViewController: UIViewController, UIScrollViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var noWordsFound: UILabel!
    
    var pointsToZoom: [CGPoint]?
    var wordsFound: [CGRect]?
    var wordCursor = 0
    
    var imageData: Data? = nil
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance()
    
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
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        return v
    }()
    
    var ocr = CognitiveServices.sharedInstance.ocr
    var image: UIImage?
    var highlightedImage: UIImage?
    var isHighlighted: Bool = false
    
    
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speak(this: "hello")
        initNextWordMenu()
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
    
    func initNextWordMenu () {
        
        let leftGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.leftArrowPressed))
        let rightGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.rightArrowPressed))
        leftArrow.isUserInteractionEnabled = true
        rightArrow.isUserInteractionEnabled = true
        leftArrow.addGestureRecognizer(leftGestureRecognizer)
        rightArrow.addGestureRecognizer(rightGestureRecognizer)
        
        noWordsFound.text = ""
        hideNextWordMenu()
    }
    
    func hideNextWordMenu () {
        leftArrow.isHidden = true
        rightArrow.isHidden = true
        noWordsFound.isHidden = true
    }
    
    func showNextWordMenu () {
        leftArrow.isHidden = false
        rightArrow.isHidden = false
        noWordsFound.isHidden = false
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
        
        dismissKeyboard()
        processAndSearch(this: searchBar.text!)
    }
    
    func processAndSearch(this key: String) {
        
        pointsToZoom = [CGPoint]()
        wordsFound = [CGRect]()
        
        for (word, coordinates) in self.ocr.wordCoordinates {
            
            var cleanedWord = word.lowercased()
            cleanedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
            cleanedWord = removeSpecialCharsFromString(text: cleanedWord)
            
            if (similarCalc(for: key.lowercased(),with: cleanedWord) >= 0.6) {
                
                let wordRect = coordinates.characters.split{$0 == ","}.map(String.init)
                let x = Double(wordRect[0])!
                let y = Double(wordRect[1])!
                let width = Double(wordRect[2])!
                let height = Double(wordRect[3])!
                
                let rect = CGRect(x: x, y: y, width: width, height: height)
                wordsFound?.append(rect)
                
                var pointToZoom = CGPoint(x: x + (width / 2), y: y + (height / 2))
                pointToZoom = convertCoordinatesForView(givenPoint: pointToZoom)
                pointsToZoom?.append(pointToZoom)
                
            }
        }
        
        if (pointsToZoom?.count)! > 0 {
            
            showNextWordMenu()
            speak(this: "Word found")
            
            highlightedImage = drawHighlightedImage(rects: wordsFound!, image: image!)
            self.imageView!.image = highlightedImage
            startBlinking()
        } else {
            hideNextWordMenu()
        }
        
    }
    
    func speak(this str: String) {
        
        myUtterance = AVSpeechUtterance(string: str)
        myUtterance.rate = 0.3
        synth.speak(myUtterance)
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890%$".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    func similarCalc(for s1: String, with s2: String) -> Float {
        let minLen = min(s1.characters.count,s2.characters.count)
        
        // we know that if the outcome here is 0.5 or lower, then the
        // property will return the lower probability. so the moment we
        // learn that probability is 0.5 or lower we can return 0.0 and
        // stop. this optimization makes a perceptible improvement in
        // overall performance.
        let maxLen = max(s1.characters.count, s2.characters.count)
        if (Double(minLen / maxLen) <= 0.5){
           return 0.0
        }
        
        // if the strings are equal we can stop right here.
        if (minLen == maxLen && s1==s2) {
           return 1.0
        }
        
        // we couldn't shortcut, so now we go ahead and compute the full
        // metric
        let dist = min(matrix(s1,secondString: s2), minLen)
        return Float(1.0 - (Double(dist) / Double(minLen)))
    }
    
    func minOfThree(one on: Int, two tw: Int , three th: Int) -> Int{
        var min = on
        if (tw < min) {min = tw}
        if (th < min) {min = th}
        return min
    }
    
    // Cost for insertion and deletion is 1, substitution is 2.
    // Based on Levenshtein distance (LD), weighted distribution not implemented
    func matrix(_ s1: String, secondString s2: String) -> Int{
        
        var matrix: [[Int]]
        let n = s1.characters.count
        let m = s2.characters.count
        var c1, c2, temp: Int
        
        if (n == 0){
            return m
        }
        
        if (m == 0){
            return n
        }
        
        matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...n {
            matrix[i][0] = i * 2
        }
        
        for j in 0...m {
            matrix[0][j] = j * 2
        }
        
        for i in 1...n {
            let numC1 = s1[s1.index(s1.startIndex, offsetBy:(i - 1))]  // s1.charAt(i - 1)
            c1 = Int((String(numC1).unicodeScalars.filter{$0.isASCII}.first?.value)!)
            
            for j in 1...m {
                let numC2 = s2[s2.index(s2.startIndex, offsetBy:(j - 1))] // s2.charAt(j - 1)
                c2 = Int((String(numC2).unicodeScalars.filter{$0.isASCII}.first?.value)!)
                
                if (c1 == c2) {
                    temp = 0
                } else {
                    temp = 2
                }
            
                matrix[i][j] = minOfThree(one: matrix[i - 1][j] + 1,two: matrix[i][j - 1] + 1, three: matrix[i - 1][j - 1] + temp)
            }
        }
    
      return matrix[n][m]
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
       
        // Change the rotation context from 0,0 to center of the image
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
    
    func drawHighlightedImage(rects: [CGRect], image: UIImage) -> UIImage {
        
        // begin a graphics context of sufficient size
        UIGraphicsBeginImageContext(image.size)
        
        // draw original image into the context
        image.draw(at: .zero)
        
        // get the context for CoreGraphics
        let context = UIGraphicsGetCurrentContext()
        
        // set stroking width and color of the context
        context!.setLineWidth(15.0)
        context!.setStrokeColor(UIColor.green.cgColor)
        
        for rect in rects {
            // Draw rect
            context!.stroke(rect)
        }
        
        // get the image from the graphics context
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the graphics context 
        UIGraphicsEndImageContext()
        
        return (resultImage)!
    }
    
    
    func leftArrowPressed(recognizer: UITapGestureRecognizer) {
        
        if (pointsToZoom != nil) && wordCursor < (pointsToZoom?.count)! {
            let p  = pointsToZoom![wordCursor]
            let wordsDisplay = String(describing: pointsToZoom?.index(of: p)) + "/" + String(describing: pointsToZoom?.count)
            noWordsFound.text = wordsDisplay
            zoomAt(point: p)
            wordCursor += 1
        }
    }
    
    func rightArrowPressed(recognizer: UITapGestureRecognizer) {
        if (pointsToZoom != nil) && wordCursor < (pointsToZoom?.count)! {
            let p  = pointsToZoom![wordCursor]
            let wordsDisplay = String(describing: pointsToZoom?.index(of: p)) + "/" + String(describing: pointsToZoom?.count)
            noWordsFound.text = wordsDisplay
            zoomAt(point: p)
            wordCursor += 1
        }
    }
    
    func zoomAt(point p: CGPoint) {
        if scrollView?.zoomScale == 1 {
            scrollView?.zoom(to: zoomRectForScale(scale: (scrollView?.maximumZoomScale)!, center: p), animated: true)
        } else {
            scrollView?.setZoomScale(1, animated: true)
        }
    }
    
    func convertCoordinatesForView (givenPoint p: CGPoint) -> CGPoint{
        
        let scrollWidth = scrollView!.bounds.width
        let scrollHeight = scrollView!.bounds.height
        
        let imageWidth = image!.size.width
        let imageHeight = image!.size.height
        
        let x = p.x * (scrollWidth / imageWidth)
        let y = p.y * (scrollHeight / imageHeight)
        
        return CGPoint(x: x, y: y)
    }
}

