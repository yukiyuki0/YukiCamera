//
//  ViewController.swift
//  YukiCamera
//
//  Created by Insu Byeon on 2019/12/06.
//  Copyright © 2019 Insu Byeon. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

final class ViewController: UIViewController {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    // MARK: - UI
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var recentImageView: UIImageView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCamera()
        self.setupObserver()
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
    
    private func setupAlbum() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        let last = fetchResult.lastObject

        if let lastAsset = last {
          let options = PHImageRequestOptions()
          options.version = .current

          PHImageManager.default().requestImage(
            for: lastAsset,
            targetSize: self.recentImageView.bounds.size,
            contentMode: .aspectFit,
            options: options,
            resultHandler: { image, _ in
              DispatchQueue.main.async {
                self.recentImageView.image = image
              }
            }
          )
        }
    }
    
    private func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func setupUserInterface() {
        // Set up preview layer
        videoPreviewLayer?.frame.size = previewView.frame.size
        
        // Set up album
        self.recentImageView.layer.borderWidth = 1
        self.recentImageView.layer.borderColor = UIColor.green.cgColor
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
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        self.setupAlbum()
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
            let confirm = UIAlertAction(title: "OK", style: .default, handler: { _ in  self.setupAlbum() })
            alert.addAction(confirm)
            present(alert, animated: true)
        }
    }
    
}
