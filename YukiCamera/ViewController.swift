//
//  ViewController.swift
//  YukiCamera
//
//  Created by Insu Byeon on 2019/12/06.
//  Copyright © 2019 Insu Byeon. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    // MARK: - UI
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUserInterface()
    }
    
    // MARK: - Setup e.t.c.
    private func setupCamera() {
        let captureDevice = AVCaptureDevice.default(for: .video)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
        } catch {
            print(error)
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewView.layer.addSublayer(videoPreviewLayer!)
        captureSession?.startRunning()
        
        // Get an instance of ACCapturePhotoOutput class
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput?.isHighResolutionCaptureEnabled = true
        // Set the output on the capture session
        captureSession?.addOutput(capturePhotoOutput!)
    }
    
    private func setupUserInterface() {
        videoPreviewLayer?.frame.size = previewView.frame.size
        applyRoundCorner(self.takePhotoButton)
    }
    
    func applyRoundCorner(_ object: UIButton) {
        object.layer.cornerRadius = (object.frame.size.width)/2
        object.layer.borderColor = UIColor.black.cgColor
        object.layer.borderWidth = 5
        object.layer.masksToBounds = true

        let anotherFrame = CGRect(x: 12, y: 12, width: object.bounds.width - 24, height: object.bounds.height - 24)
        let circle = CAShapeLayer()
        let path = UIBezierPath(arcCenter: object.center, radius: anotherFrame.width / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        circle.path = path.cgPath
        circle.strokeColor = UIColor.black.cgColor
        circle.lineWidth = 1.0
        circle.fillColor = UIColor.clear.cgColor
        object.layer.addSublayer(circle)
    }
    
    // MARK: - Actions
    @IBAction func onTapTakePhoto(_ sender: Any) {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        // Call capturePhoto method by passing our photo settings and a
        // delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    
}

// MARK: - AVCapturePhotoCaptureDelegate
extension ViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        guard let imageData = photo.fileDataRepresentation() else { return }
        // Initialise a UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
        // Save our captured image to photos album
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            let alert = UIAlertController(title: "Saved a photo", message: nil, preferredStyle: .alert)
            let confirm = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(confirm)
            present(alert, animated: true)
        }
    }
    
}
