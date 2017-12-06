//
//  ViewController.swift
//  Supervision Search
//
//  Created by Gautam on 10/25/17.
//  Copyright © 2017 Gautam. All rights reserved.

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var zoomSlider: UISlider!
    @IBOutlet weak var plus: UIImageView!
    @IBOutlet weak var minus: UIImageView!
    @IBOutlet weak var info: UIButton!
    
    let cognitiveServices = CognitiveServices.sharedInstance
    
    var capturePhotoOutput = AVCapturePhotoOutput()
    let previewView = VideoPreviewView()
    let captureSession = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "session queue")
    var isCaptureSessionConfigured = false // Instance proprerty on this view controller class
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isCaptureSessionConfigured {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        } else {
            // First time: request camera access, configure capture session and start it.
            self.checkCameraAuthorization({ authorized in
                guard authorized else {
                    print("Permission to use camera denied.")
                    return
                }
                self.sessionQueue.async {
                    self.configureCaptureSession({ success in
                        guard success else { return }
                        self.isCaptureSessionConfigured = true
                        self.captureSession.startRunning()
                    })
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppUtility.lockOrientation(.all)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(.portrait)
        
        self.checkCameraAuthorization { authorized in
            if !authorized {
                self.keepShowingCameraNeededAlert()
            }
        }
    }
    
    
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
        self.checkCameraAuthorization { authorized in
            if authorized {
                // Proceed to set up and use the camera.
                
                self.previewView.session = self.captureSession
                self.previewView.aspectRatio = AVLayerVideoGravity.resizeAspectFill as AVLayerVideoGravity
                self.previewView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.pinchDetected)))
                
                let photoSettings = AVCapturePhotoSettings()
                photoSettings.isAutoStillImageStabilizationEnabled = true
                photoSettings.flashMode = .auto
                photoSettings.isHighResolutionPhotoEnabled = true
                
                self.setZoom(toFactor: 1.0)
            }
        }
        setupViews()
    }
    
    func keepShowingCameraNeededAlert () {
        let alertController = UIAlertController(title: "Hey there!", message: "We need your camera permission to work.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in self.keepShowingCameraNeededAlert()}))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func defaultDevice() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInDuoCamera,
                                                for: AVMediaType.video,
                                                position: .back) {
            return device // use dual camera on supported devices
        } else if let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                                       for: AVMediaType.video,
                                                       position: .back) {
            return device // use default back facing camera otherwise
        } else {
            fatalError("All supported devices are expected to have at least one of the queried capture devices.")
        }
    }
    
    func configureCaptureSession(_ completionHandler: ((_ success: Bool) -> Void)) {
        var success = false
        defer { completionHandler(success) } // Ensure all exit paths call completion handler.
        
        // Get video input for the default camera.
        let videoCaptureDevice = defaultDevice()
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("Unable to obtain video input for default camera.")
            return
        }
        
        // Create and configure the photo output.
        let capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput.isHighResolutionCaptureEnabled = true
        capturePhotoOutput.isLivePhotoCaptureEnabled = capturePhotoOutput.isLivePhotoCaptureSupported
        
        // Make sure inputs and output can be added to session.
        guard self.captureSession.canAddInput(videoInput) else { return }
        guard self.captureSession.canAddOutput(capturePhotoOutput) else { return }
        
        // Configure the session.
        self.captureSession.beginConfiguration()
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        self.captureSession.addInput(videoInput)
        self.captureSession.addOutput(capturePhotoOutput)
        self.captureSession.commitConfiguration()
        
        self.capturePhotoOutput = capturePhotoOutput
        success = true
    }
    
    func setupViews () {
        
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        previewView.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true
        
        zoomSlider.translatesAutoresizingMaskIntoConstraints = false
        zoomSlider.transform = CGAffineTransform.init(rotationAngle: -(CGFloat(CGFloat.pi/2)))
        
        zoomSlider.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width/8).isActive = true
        zoomSlider.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        zoomSlider.widthAnchor.constraint(equalToConstant: view.frame.height/3).isActive = true
        
        zoomSlider.minimumValue = 1.0
        zoomSlider.maximumValue = 10
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
        info.centerYAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height/10).isActive = true
        info.widthAnchor.constraint(equalToConstant: view.frame.width/10).isActive = true
        info.heightAnchor.constraint(equalToConstant: view.frame.width/10).isActive = true
        
        findButton.translatesAutoresizingMaskIntoConstraints = false
        findButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        findButton.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -((view.frame.width/4))).isActive = true
        findButton.widthAnchor.constraint(equalToConstant: view.frame.width/4).isActive = true
        findButton.heightAnchor.constraint(equalToConstant: view.frame.width/4).isActive = true
        
        cameraPreview.addSubview(previewView)
        cameraPreview.bringSubview(toFront: zoomSlider)
        cameraPreview.bringSubview(toFront: findButton)
        cameraPreview.bringSubview(toFront: plus)
        cameraPreview.bringSubview(toFront: minus)
        cameraPreview.bringSubview(toFront: info)
        
    }
    
    func backPressed (_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func zoomChanged(_ sender: UISlider) {
        // let factor = CGFloat(powf(1.05,sender.value))
        let factor = CGFloat(sender.value)
        print(factor)
        setZoom(toFactor: factor)
    }
    
    @IBAction func findPressed(_ sender: UIButton) {
        
        // self.view.addSubview(UIView.init(frame: self.view.frame))
        Progress.shared.showProgressView(self.view)
        self.cameraPreview.removeFromSuperview()
        
        // Capture code
        let capturePhotoOutput = self.capturePhotoOutput
        let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation
        self.sessionQueue.async {
            // Update the photo output's connection to match the video orientation of the video preview layer.
            if let photoOutputConnection = capturePhotoOutput.connection(with: AVMediaType.video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            }
            
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.flashMode = .auto
            
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    var photoSampleBuffer: CMSampleBuffer?
    var previewPhotoSampleBuffer: CMSampleBuffer?
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                 didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                 previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                 resolvedSettings: AVCaptureResolvedPhotoSettings,
                 bracketSettings: AVCaptureBracketedStillImageSettings?,
                 error: Error?) {
        guard error == nil, let photoSampleBuffer = photoSampleBuffer else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        self.photoSampleBuffer = photoSampleBuffer
        self.previewPhotoSampleBuffer = previewPhotoSampleBuffer
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                 didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                 error: Error?) {
        guard error == nil else {
            print("Error in capture process: \(String(describing: error))")
            return
        }
        
        if let photoSampleBuffer = self.photoSampleBuffer {
            segueBufferToImageViewController(photoSampleBuffer,
                                           previewSampleBuffer: self.previewPhotoSampleBuffer,
                                           completionHandler: { success, error in
                                            if success {
                                                print("Added JPEG photo to library.")
                                            } else {
                                                print("Error adding JPEG photo to library: \(String(describing: error))")
                                            }
            })
        }
    }
    
    func segueBufferToImageViewController(_ sampleBuffer: CMSampleBuffer,
                                        previewSampleBuffer: CMSampleBuffer?,
                                        completionHandler: ((_ success: Bool, _ error: Error?) -> Void)?) {

        
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(
            forJPEGSampleBuffer: sampleBuffer,
            previewPhotoSampleBuffer: previewSampleBuffer)
            else {
                print("Unable to create JPEG data.")
                completionHandler?(false, nil)
                return
        }
        
        
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
        nextViewController.imageData = imageData
        self.present(nextViewController, animated:false, completion:nil)
    }

    func getDeviceMaxZoom() -> CGFloat {
        let device: AVCaptureDevice = defaultDevice()
        return device.activeFormat.videoMaxZoomFactor
    }
    
    @objc func pinchDetected (sender: UIPinchGestureRecognizer) {
        let device = defaultDevice()
        if sender.state == .changed {
            let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
            let pinchVelocityDividerFactor: CGFloat = 5.0
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                
                let desiredZoomFactor = device.videoZoomFactor + atan2(sender.velocity, pinchVelocityDividerFactor)
                let zoomValue = max(1.0, min(desiredZoomFactor, maxZoomFactor))
                device.videoZoomFactor = zoomValue
                self.zoomSlider.value = Float(zoomValue) // track the seek bar
            } catch {
                print(error)
            }
        }
    }

    func setZoom(toFactor vZoomFactor: CGFloat) {
        var device: AVCaptureDevice = defaultDevice()
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
    
    func checkCameraAuthorization(_ completionHandler: @escaping ((_ authorized: Bool) -> Void)) {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            //The user has previously granted access to the camera.
            completionHandler(true)
            
        case .notDetermined:
            // The user has not yet been presented with the option to grant video access so request access.
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { success in
                completionHandler(success)
            })
            
        case .denied:
            // The user has previously denied access.
            completionHandler(false)
            
        case .restricted:
            // The user doesn't have the authority to request access e.g. parental restriction.
            completionHandler(false)
        }
    }
}


class VideoPreviewView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    var aspectRatio: AVLayerVideoGravity {
        get { return videoPreviewLayer.videoGravity as AVLayerVideoGravity }
        set { videoPreviewLayer.videoGravity = newValue }
    }
    var session: AVCaptureSession? {
        get { return videoPreviewLayer.session }
        set { videoPreviewLayer.session = newValue }
    }
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
