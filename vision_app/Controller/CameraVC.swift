//
//  ViewController.swift
//  vision_app
//
//  Created by Grazietta Hof on 2017-10-15.
//  Copyright © 2017 Grazietta Hof. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision



class CameraVC: UIViewController {
    
    
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    
    @IBOutlet weak var imageName_label: UILabel!
    @IBOutlet weak var roundedLabelView: RoundedShadow!
    @IBOutlet weak var flashButton: roundedButton!
    @IBOutlet weak var cameraView: roundedImageView!
    @IBOutlet weak var captureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1 //tap only once
        
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)

        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            cameraOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(cameraOutput) == true {
                captureSession.addOutput(cameraOutput!)
            }
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect //maintaining aspect ratio
            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            cameraView.layer.addSublayer(previewLayer!)
            cameraView.addGestureRecognizer(tap)
            captureSession.startRunning()
           } catch {
            debugPrint("error")
        }
    }

    @objc func didTapCameraView() {
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func deal_with_results(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        
        for classification in results {
            if classification.confidence < 0.5 {
                self.imageName_label.text = "I do not know what this is. :( Please try again"
                break
            } else {
                self.imageName_label.text = classification.identifier
                break
            }
        }
    }
}

extension CameraVC: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            
            do{
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: deal_with_results)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            }catch {
                //handle errors
                debugPrint(error)
            }
            let image = UIImage(data: photoData!)
            self.captureImageView.image = image
        }
    }
}



















