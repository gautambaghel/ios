//
//  ViewController.swift
//  Supervision Search
//
//  Created by Gautam on 10/25/17.
//  Copyright © 2017 Gautam. All rights reserved.
//
import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var zoomSlider: UISlider!
    @IBOutlet weak var plus: UIImageView!
    @IBOutlet weak var minus: UIImageView!
    @IBOutlet weak var info: UIImageView!
    
    let cognitiveServices = CognitiveServices.sharedInstance
    let stillImageOutput = AVCaptureStillImageOutput()
    
    var videoDevice: AVCaptureDevice? = nil
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        let devices = AVCaptureDevice.devices().filter{ ($0 as AnyObject).hasMediaType(AVMediaTypeVideo) && ($0 as AnyObject).position == AVCaptureDevicePosition.back }
        
        if let captureDevice = devices.first as? AVCaptureDevice{
            
            videoDevice = captureDevice
            do{
                if (captureDevice.hasTorch)
                {
                    try captureDevice.lockForConfiguration()
                    captureDevice.torchMode = .auto
                    captureDevice.flashMode = .auto
                    captureDevice.unlockForConfiguration()
                }
            }catch{
                print("Device tourch Flash Error ");
            }
            
            do {
                try
                    captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
                captureSession.sessionPreset = AVCaptureSessionPresetHigh // AVCaptureSessionPresetPhoto
                captureSession.startRunning()
                stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                if captureSession.canAddOutput(stillImageOutput) {
                    captureSession.addOutput(stillImageOutput)
                }
                
                if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                    previewLayer.bounds =  cameraPreview.bounds
                    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    previewLayer.connection?.videoOrientation = .portrait
                    cameraPreview.layer.insertSublayer(previewLayer, at: 0)
                    previewLayer.frame = CGRect(x: 0,y: 0,width: self.view.bounds.width,height: self.view.bounds.height)
                    // cameraPreview.frame
                    
                    let pinch = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.pinchDetected))
                    cameraPreview.addGestureRecognizer(pinch)
                }
                
            } catch {
                print("some error")
            }
        }
        
        setupSlider()
        setZoom(toFactor: 1.0)
    }
    
    func setupSlider () {
        
        zoomSlider.translatesAutoresizingMaskIntoConstraints = false
        zoomSlider.transform = CGAffineTransform.init(rotationAngle: -(CGFloat(CGFloat.pi/2)))
        
        zoomSlider.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width/8).isActive = true
        zoomSlider.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        zoomSlider.widthAnchor.constraint(equalToConstant: view.frame.height/3).isActive = true
        
        zoomSlider.minimumValue = 1.0
        zoomSlider.maximumValue = Float(getDeviceMaxZoom() / 10)
        zoomSlider.isContinuous = true
        zoomSlider.value = 1.0
        zoomSlider.tintColor = UIColor.black
        
        plus.translatesAutoresizingMaskIntoConstraints = false
        plus.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width/8).isActive = true
        plus.centerYAnchor.constraint(equalTo: view.topAnchor, constant: (view.frame.height/3) - 20).isActive = true
        plus.widthAnchor.constraint(equalToConstant: zoomSlider.frame.width).isActive = true
        plus.heightAnchor.constraint(equalToConstant: zoomSlider.frame.width).isActive = true
        
        minus.translatesAutoresizingMaskIntoConstraints = false
        minus.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width/8).isActive = true
        minus.centerYAnchor.constraint(equalTo: view.topAnchor, constant: (view.frame.height - view.frame.height/3) + 20).isActive = true
        minus.widthAnchor.constraint(equalToConstant: zoomSlider.frame.width).isActive = true
        minus.heightAnchor.constraint(equalToConstant: zoomSlider.frame.width).isActive = true
        
        info.translatesAutoresizingMaskIntoConstraints = false
        info.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width/10).isActive = true
        info.centerYAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.width/10).isActive = true
        info.widthAnchor.constraint(equalToConstant: view.frame.width/10).isActive = true
        info.heightAnchor.constraint(equalToConstant: view.frame.width/10).isActive = true
        
    }
    
    @IBAction func zoomChanged(_ sender: UISlider) {
        setZoom(toFactor: CGFloat(sender.value))
    }
    
    @IBAction func findPressed(_ sender: UIButton) {
        
        // self.view.addSubview(UIView.init(frame: self.view.frame))
        Progress.shared.showProgressView(self.view)
        self.cameraPreview.removeFromSuperview()
        
        // Take a picture from back camera
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
                nextViewController.imageData = imageData
                self.present(nextViewController, animated:false, completion:nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    func pinchDetected (pinch: UIPinchGestureRecognizer) {
        let vZoomFactor = pinch.scale
        zoomSlider.value = Float(vZoomFactor)
        setZoom(toFactor: vZoomFactor)
    }
    
    func getDeviceMaxZoom() -> CGFloat {
        let device: AVCaptureDevice = self.videoDevice!
        return device.activeFormat.videoMaxZoomFactor
    }
    
    func setZoom(toFactor vZoomFactor: CGFloat) {
        var device: AVCaptureDevice = self.videoDevice!
        var error:NSError!
        do{
            try device.lockForConfiguration()
            defer {device.unlockForConfiguration()}
            if (vZoomFactor <= device.activeFormat.videoMaxZoomFactor && vZoomFactor >= 1.0){
                // device.ramp(toVideoZoomFactor: vZoomFactor, withRate: 1)
                 device.videoZoomFactor = vZoomFactor
            }
            else if (vZoomFactor <= 1.0){ NSLog("Unable to set videoZoom: (max %f, asked %f)", device.activeFormat.videoMaxZoomFactor, vZoomFactor) }
            else{ NSLog("Unable to set videoZoom: (max %f, asked %f)", device.activeFormat.videoMaxZoomFactor, vZoomFactor) }
        }
            
        catch error as NSError{ NSLog("Unable to set videoZoom: %@", error.localizedDescription) }
        catch _{ NSLog("Unable to set videoZoom: %@", error.localizedDescription) }
    }
}

