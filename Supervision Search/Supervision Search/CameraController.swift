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
        var device: AVCaptureDevice = self.videoDevice!
        var vZoomFactor = pinch.scale
        var error:NSError!
        do{
            try device.lockForConfiguration()
            defer {device.unlockForConfiguration()}
            if (vZoomFactor <= device.activeFormat.videoMaxZoomFactor && vZoomFactor >= 1.0){
                device.ramp(toVideoZoomFactor: vZoomFactor, withRate: 1)
                // device.videoZoomFactor = vZoomFactor
            }
            else if (vZoomFactor <= 1.0){ NSLog("Unable to set videoZoom: (max %f, asked %f)", device.activeFormat.videoMaxZoomFactor, vZoomFactor) }
            else{ NSLog("Unable to set videoZoom: (max %f, asked %f)", device.activeFormat.videoMaxZoomFactor, vZoomFactor) }
        }
        
          catch error as NSError{ NSLog("Unable to set videoZoom: %@", error.localizedDescription) }
          catch _{ NSLog("Unable to set videoZoom: %@", error.localizedDescription) }
    }
    
}

