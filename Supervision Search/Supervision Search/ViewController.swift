//
//  ViewController.swift
//  Supervision Search
//
//  Created by Gautam on 10/25/17.
//  Copyright © 2017 Gautam. All rights reserved.
//
import UIKit
import AVFoundation

class ViewController: UIViewController , UIScrollViewDelegate{
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var cameraPreview: UIView!
    var imageView: UIImageView?
    var scrollView: UIScrollView?
    
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
                    
                    // cameraPreview.layer.addSublayer(previewLayer)
                    // view.addSubview(cameraPreview)
                    
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
                let imageFrame = CGRect(origin: CGPoint(x: 0,y :0),
                                               size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
                self.imageView!.frame = imageFrame
                self.view.willRemoveSubview(self.cameraPreview)
                self.view.addSubview(self.imageView!)
                
                let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.doubleTapDetected))
                doubleTap.numberOfTapsRequired = 2
                self.imageView?.isUserInteractionEnabled = true
                self.imageView?.addGestureRecognizer(doubleTap)
                
            }
        }
    }
    
    func doubleTapDetected() {
        print("Imageview Clicked")
    }
    
}

