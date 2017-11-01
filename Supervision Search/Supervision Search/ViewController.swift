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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        
        let captureSession = AVCaptureSession()
        
        let devices = AVCaptureDevice.devices().filter{ ($0 as AnyObject).hasMediaType(AVMediaTypeVideo) && ($0 as AnyObject).position == AVCaptureDevicePosition.back }
        
        if let captureDevice = devices.first as? AVCaptureDevice{
            
            do {
                try
                    
                    captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
                captureSession.sessionPreset = AVCaptureSessionPresetPhoto
                captureSession.startRunning()
                stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                if captureSession.canAddOutput(stillImageOutput) {
                    captureSession.addOutput(stillImageOutput)
                }
                
                if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                    previewLayer.bounds = cameraPreview.bounds
                    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    previewLayer.connection?.videoOrientation = .portrait
                    cameraPreview.layer.insertSublayer(previewLayer, at: 0)
                    previewLayer.frame = cameraPreview.frame
                    
                }
                
            } catch {
                print("some error")
            }
            
        }
        
        
    }
    
    @IBAction func findPressed(_ sender: UIButton) {
        
        // Take a picture from back camera
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                
                self.cameraPreview.removeFromSuperview()
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
                nextViewController.imageData = imageData
                self.present(nextViewController, animated:false, completion:nil)
                              
            }
        }
    }
      
}

