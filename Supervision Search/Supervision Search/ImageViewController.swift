//
//  ImageViewController.swift
//  Supervision Search
//
//  Created by Gautam on 10/31/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import AudioToolbox
import SystemConfiguration

class ImageViewController: UIViewController, UIScrollViewDelegate, UISearchBarDelegate , SFSpeechRecognizerDelegate {

    @IBOutlet weak var zoomButton: UIImageView!
    @IBOutlet weak var retry: UIImageView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var noWordsFound: UILabel!
    
    var pointsToZoom: [CGPoint]?
    var wordsFound: [CGRect]?
    var wordCursor = 0
    var firstTimePressFlag = true
    var isBlinking = false
    
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
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        return v
    }()
    
    var ocr = CognitiveServices.sharedInstance.ocr
    var image: UIImage?
    var highlightedImage: UIImage?
    var isHighlighted: Bool = false
    var textField: UILabel?
    
    @IBOutlet weak var mainView: UIView!
    
    // Speech stuff
    private var speechRecognizer: SFSpeechRecognizer? = nil
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()
    
    private var alertController: UIAlertController? = nil
    private var responseRecieved = false
    private let synth = AVSpeechSynthesizer()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
//        let preferences = UserDefaults.standard
//        let helloKey = "helloKey"
//        preferences.set(nil, forKey: helloKey)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if !helloSaid() {
//            speak(this: "hello")
//            saveState(to: "true")
//        }
        
        initNextWordMenu()
        retry.isHidden = true
        searchBar.delegate = self
        image = UIImage(data: imageData!)!
        
        // start the spinner
        Progress.shared.showProgressView(self.view)
        
        // start a count down timer (of sorts)
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: {
            
            Progress.shared.hideProgressView()
            if !self.isInternetAvailable() {
                self.speak(this: "Turn on the internet to use this app.")
            } else if !self.responseRecieved {
                self.speak(this: "Internal error tap to retry")
                self.retry.isHidden = false
                let retryGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.retryPressed))
                self.retry.isUserInteractionEnabled = true
                self.retry.addGestureRecognizer(retryGestureRecognizer)
            }
        })
        
        // COGINITITON STUFF
        doCognititonInBackground()
        
        // View init stuff
        setupImageInImageview()
        setupTextAboveSearchBar()
        
    }
    
    func helloSaid() -> Bool {
        let preferences = UserDefaults.standard
        let helloKey = "helloKey"
        
        if preferences.string(forKey: helloKey) != nil {
            return true
        } else {
            return false
        }
    }
    
    func saveState(to state: String) {
        let preferences = UserDefaults.standard
        let helloKey = "helloKey"
        
        preferences.set(state, forKey: helloKey)
        preferences.synchronize()
    }
    
    func doCognititonInBackground(){
        DispatchQueue.global(qos: .background).async {
            let requestObject: OCRRequestObject = (resource: self.imageData!, language: .Automatic, detectOrientation: true)
            try! self.ocr.recognizeCharactersWithRequestObject(requestObject, completion: { (response, error) in
                if (response != nil){
                    DispatchQueue.main.async {
                        self.responseRecieved = true
                        let _ = self.ocr.extractStringFromDictionary(response!)
                        
                        Progress.shared.hideProgressView()
                        self.orientImage()
                    }
                } else if error != "" {
                    DispatchQueue.main.async { self.speak(this: error) }
                }
            })
        }
    }
    
    func setupTextAboveSearchBar () {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 60))
        customView.backgroundColor = UIColor.red
        
        textField = UILabel(frame: CGRect(x: 20, y: 0, width: 600, height: 60))
        textField?.font = textField?.font.withSize(25)
        textField?.textColor = .white
        customView.addSubview(textField!)
        searchBar.inputAccessoryView = customView
    }
    
    func setupSpeechStuff() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
        
        microphoneButton.isEnabled = false
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        do {
            try audioSession.setCategory(AVAudioSessionModeSpokenAudio)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        // TODO changed this false,  revert to true if needed
        recognitionRequest.shouldReportPartialResults = false
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            if result != nil {
                self.stopMicAndProcess(result!, valid: true)
            }
            
            if error != nil {
                self.speak(this: "Sorry didn't catch that")
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func stopMicAndProcess (_ result: SFSpeechRecognitionResult, valid resultIsValid: Bool) {
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        self.alertController!.dismiss(animated: true, completion: nil)
        self.recognitionRequest?.endAudio()
        self.recognitionTask?.finish()
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        self.microphoneButton.isEnabled = true
        
        try? self.audioSession.setActive(false, with: .notifyOthersOnDeactivation)
        
        if resultIsValid {
           self.searchBar.text = result.bestTranscription.formattedString
           self.processAndSearch()
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    func initNextWordMenu () {
        
        let leftGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.leftArrowPressed))
        let rightGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.rightArrowPressed))
        let zoomGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.zoomPressed))
        
        leftArrow.isUserInteractionEnabled = true
        rightArrow.isUserInteractionEnabled = true
        zoomButton.isUserInteractionEnabled = true
        
        leftArrow.addGestureRecognizer(leftGestureRecognizer)
        rightArrow.addGestureRecognizer(rightGestureRecognizer)
        zoomButton.addGestureRecognizer(zoomGestureRecognizer)
        
        noWordsFound.text = ""
        hideNextWordMenu()
    }
    
    func hideNextWordMenu () {
        leftArrow.isHidden = true
        rightArrow.isHidden = true
        noWordsFound.isHidden = true
        zoomButton.isHidden = true
    }
    
    func showNextWordMenu () {
        leftArrow.isHidden = false
        rightArrow.isHidden = false
        noWordsFound.isHidden = false
    }
    
    func setupImageInImageview() {
        
        //remove the earlier view
        self.scrollView?.removeFromSuperview()
        
        self.imageView!.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        self.imageView!.image = image
        let imageFrame = CGRect(origin: CGPoint(x: 0,y :0),
                                size: CGSize(width: mainView.bounds.width, height: mainView.bounds.height))
        self.imageView!.frame = imageFrame
        
        self.scrollView?.frame = mainView.bounds
        self.scrollView?.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
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
        
        setupSpeechStuff()
        
        if !audioSession.isOtherAudioPlaying && !audioEngine.isRunning {
            if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
                AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                    if granted {
                        self.playRecordStartSound()
                        self.tryRecording()
                    } else {
                        self.microphoneButton.isEnabled = false
                    }
                })
            }
        }
    }
    
    func tryRecording () {
    
        if synth.isSpeaking {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: { self.tryRecording() } )
        } else {
            self.alertController = UIAlertController(title: "Speak", message: "Go ahead, I'm listening", preferredStyle: .alert)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                self.alertController?.dismiss(animated: true, completion: nil)
                self.stopMicAndProcess(SFSpeechRecognitionResult.init(), valid: false)
            })
            let cancel = UIAlertAction(title: "Done", style: .cancel, handler:  { action in
                self.alertController?.dismiss(animated: true, completion: nil)
                self.stopMicAndProcess(SFSpeechRecognitionResult.init(), valid: false)
            })
            
            let image = resizeImage(UIImage(named: "microphone")!, targetSize: CGSize(width: 60, height: 60))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 60, height: 60))
            imageView.image = image
            self.alertController!.view.addSubview(imageView)
            self.alertController!.addAction(cancel)
            self.present(self.alertController!, animated: true, completion: nil)
            self.startRecording()
        }
    }
    
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func playRecordStartSound() {
        speak(this: "Speak")
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        textField?.text = searchBar.text!
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Each letter added
        textField?.text = searchBar.text!
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        processAndSearch()
    }
    
    func processAndSearch() {
        
        let key = searchBar.text!
        if key == "" {
            return
        }
        wordCursor = 0
        firstTimePressFlag = true
        pointsToZoom = [CGPoint]()
        wordsFound = [CGRect]()
        
        for (word, coordinates) in self.ocr.wordCoordinates {
            
            var cleanedWord = word.lowercased()
            cleanedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
            cleanedWord = removeSpecialCharsFromString(text: cleanedWord)
            
            if (similarCalc(for: key.lowercased(),with: cleanedWord) >= 0.6) {
                
                for wordRect in coordinates {
                    
                    let wRect = wordRect.split(separator: ",").map(String.init)
                    let x = Double(wRect[0])!
                    let y = Double(wRect[1])!
                    let width = Double(wRect[2])!
                    let height = Double(wRect[3])!
                    
                    let rect = CGRect(x: x, y: y, width: width, height: height)
                    wordsFound?.append(rect)
                    
                    var pointToZoom = CGPoint(x: x + (width / 2), y: y + (height / 2))
                    pointToZoom = convertCoordinatesForView(givenPoint: pointToZoom)
                    pointsToZoom?.append(pointToZoom)
                    
                }
            }
        }
        
        if (pointsToZoom?.count)! > 0 {
            pointsToZoom = pointsToZoom?.sorted(by: {$0.y < $1.y})
            if (pointsToZoom?.count)! > 1 {
                showNextWordMenu()
                leftArrow(show: false)
                zoomButton.isHidden = true
                speak(this: "\(key) found at \((pointsToZoom?.count)!) locations")
            } else {
                speak(this: "\(key) found at one location")
                hideNextWordMenu()
                zoomButton.isHidden = false
            }
            
            noWordsFound.text = String(describing: (pointsToZoom?.count)!)
            highlightedImage = drawHighlightedImage(rects: wordsFound!, image: image!)
            self.imageView!.image = highlightedImage
            if !isBlinking {
                self.startBlinking()
            }
        } else {
            hideNextWordMenu()
            speak(this: "\(key) not found")
        }
        
    }
    
    func speak(this str: String) {
        let myUtterance = AVSpeechUtterance(string: str)
        // myUtterance.rate = 0.4
        myUtterance.volume = 1
        synth.speak(myUtterance)
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890%$")
        return String(text.filter {okayChars.contains($0) })
    }
    
    func similarCalc(for s1: String, with s2: String) -> Float {
        let minLen = min(s1.count,s2.count)
        
        // we know that if the outcome here is 0.5 or lower, then the
        // property will return the lower probability. so the moment we
        // learn that probability is 0.5 or lower we can return 0.0 and
        // stop. this optimization makes a perceptible improvement in
        // overall performance.
        let maxLen = max(s1.count, s2.count)
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
    
    func minOfThree(one o: Int, two tw: Int , three th: Int) -> Int{
        var min = o
        if (tw < min) {min = tw}
        if (th < min) {min = th}
        return min
    }
    
    // Cost for insertion and deletion is 1, substitution is 2.
    // Based on Levenshtein distance (LD), weighted distribution not implemented
    func matrix(_ s1: String, secondString s2: String) -> Int{
        
        var matrix: [[Int]]
        let n = s1.count
        let m = s2.count
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
        return s1 * Float(Float.pi/180)
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
        isBlinking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            if self.isBlinking {
                if self.isHighlighted {
                    self.imageView!.image = self.image
                    self.isHighlighted = false
                } else {
                    self.imageView!.image = self.highlightedImage
                    self.isHighlighted = true
                }
                self.startBlinking()
            }
        })
    }
    
    func stopBlinking() {
        isBlinking = false
    }
    
    func drawHighlightedImage(rects: [CGRect], image: UIImage) -> UIImage {
        
        // begin a graphics context of sufficient size
        UIGraphicsBeginImageContext(image.size)
        
        // draw original image into the context
        image.draw(at: .zero)
        
        // get the context for CoreGraphics
        let context = UIGraphicsGetCurrentContext()
        
        // set stroking width and color of the context
        context!.setStrokeColor(UIColor.green.cgColor)
        
        for rect in rects {
            // Draw rect
            let lineWidth = max((rect.height / 5),10)
            context!.setLineWidth(lineWidth)
            // context!.stroke(rect)
            let firstPoint = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height)
            let secondPoint = CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height)
            context!.move(to: firstPoint)
            context!.addLine(to: secondPoint)
            context!.closePath()
            context!.strokePath()
        }
        
        // get the image from the graphics context
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the graphics context 
        UIGraphicsEndImageContext()
        
        return (resultImage)!
    }
    
    
    func leftArrowPressed(recognizer: UITapGestureRecognizer) {
        
        if (pointsToZoom != nil) {
            
            if((wordCursor - 1) <= 0){
                leftArrow(show: false)
            }
                
            if wordCursor > 0 { wordCursor -= 1 }
            
            let p  = pointsToZoom![wordCursor]
            let wordsDisplay = String(describing: ((pointsToZoom?.index(of: p))! + 1)) + "/" + String(describing: (pointsToZoom?.count)!)
            noWordsFound.text = wordsDisplay
            zoomAt(point: p)
            rightArrow(show: true)
        }
    }
    
    func rightArrowPressed (recognizer: UITapGestureRecognizer) {
        if (pointsToZoom != nil) && wordCursor < (pointsToZoom?.count)! {
            
            if firstTimePressFlag {
                firstTimePressFlag = false
            } else {
                
                if((wordCursor + 1) == ((pointsToZoom?.count)! - 1)){
                    rightArrow(show: false)
                }
                
                wordCursor += 1
                leftArrow(show: true)

            }
            let p  = pointsToZoom![wordCursor]
            let wordsDisplay = String(describing: ((pointsToZoom?.index(of: p))! + 1)) + "/" + String(describing: (pointsToZoom?.count)!)
            noWordsFound.text = wordsDisplay
            zoomAt(point: p)
            
        }
    }
    
    func zoomPressed (recognizer: UITapGestureRecognizer)  {
        if (pointsToZoom != nil) {
            zoomAt(point: pointsToZoom![0])
        }
    }
    
    func retryPressed (recognizer: UITapGestureRecognizer) {
        retry.isHidden = true
        self.responseRecieved = false
        stopBlinking()
        image = UIImage(data: imageData!)!
        initNextWordMenu()
        doCognititonInBackground()
    }
    
    func leftArrow(show s: Bool){
        leftArrow.isHidden = !s
    }
    
    func rightArrow(show s: Bool){
        rightArrow.isHidden = !s
    }
    
    func zoomAt(point p: CGPoint) {
        if scrollView?.zoomScale == 1 {
            scrollView?.zoom(to: zoomRectForScale(scale: (scrollView?.maximumZoomScale)!, center: p), animated: true)
        } else {
            disableArrows()
            scrollView?.setZoomScale(1, animated: true)
            doubleZoomAt(point: p)
        }
    }
    
    func doubleZoomAt (point p: CGPoint) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
            self.scrollView?.zoom(to: self.zoomRectForScale(scale: (self.scrollView?.maximumZoomScale)!, center: p), animated: true)
            self.enableArrows()
        })
    }
    
    func disableArrows () {
        rightArrow.isUserInteractionEnabled = false
        leftArrow.isUserInteractionEnabled = false
    }
    
    func enableArrows () {
        rightArrow.isUserInteractionEnabled = true
        leftArrow.isUserInteractionEnabled = true
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
    
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
}

