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
    var imageView: UIImageView?
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
                    previewLayer.bounds = view.bounds
                    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    let cameraPreview = UIView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: view.bounds.size.width, height: view.bounds.size.height)))
                    cameraPreview.layer.addSublayer(previewLayer)
                    view.addSubview(cameraPreview)
                    
                    view.addSubview(findButton)
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
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                let image: UIImage = UIImage(data: imageData!)!
                self.imageView = UIImageView(image: image)
                self.imageView!.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 200))
                self.view.addSubview(self.imageView!)
            }
        }
    }
    
    
}

