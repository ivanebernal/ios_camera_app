//
//  ViewController.swift
//  CameraDemo
//
//  Created by Ivan Esparza on 2/6/19.
//  Copyright © 2019 ivanebernal. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

  @IBOutlet weak var previewView: PreviewView!
  @IBOutlet weak var flipCameraButton: UIButton!
  @IBOutlet weak var captureButton: UIButton!
  
  lazy var frontCameraInput: AVCaptureDeviceInput? = {
    let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    return try? AVCaptureDeviceInput(device: device!)
  } ()
  lazy var backCameraInput: AVCaptureDeviceInput? = {
    let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    return try? AVCaptureDeviceInput(device: device!)
  } ()
  let photoOutput = AVCapturePhotoOutput()
  let session = AVCaptureSession()
  var currentPosition: AVCaptureDevice.Position = .back
  
  override func viewDidLoad() {
    super.viewDidLoad()
    DemoClass.printHelloWorld()
    configureViews()
    checkCameraPermission {
      self.prepareCameraSession()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    session.startRunning()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    session.stopRunning()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let sender = sender as? Photo,
    let detailVC = segue.destination as? PhotoViewController else { return }
    detailVC.image = sender
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: { (context) in
      let orientation = UIApplication.shared.statusBarOrientation
      self.configureCameraOrientation(with: orientation)
    }) { (context) in
      //TODO
    }
  }
  
  @objc func flipCamera() {
    session.beginConfiguration()
    if session.isRunning,
      let frontCamIn = frontCameraInput,
      let backCamIn = backCameraInput{
      switch currentPosition {
      case .back:
        session.removeInput(backCamIn)
        if session.canAddInput(frontCamIn) {
          session.addInput(frontCamIn)
          currentPosition = .front
        }
      case .front, .unspecified: //specify all cases of an enum
        session.removeInput(frontCamIn)
        if session.canAddInput(backCamIn){
          session.addInput(backCamIn)
          currentPosition = .back
        }
      }
    }
    session.commitConfiguration()
  }
  
  @objc func capturePhoto() {
    if let videoOrientation = previewView.videoPreviewLayer.connection?.videoOrientation,
      let connection = photoOutput.connection(with: .video){
      connection.videoOrientation = videoOrientation
    }
    let settings = AVCapturePhotoSettings()
    photoOutput.capturePhoto(with: settings, delegate: self)
  }
  
  fileprivate func configureViews() {
    flipCameraButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
    captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
    configureCameraOrientation()
  }
  
  fileprivate func configureCameraOrientation(with orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation) {
    if let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) {
      previewView.videoPreviewLayer.connection?.videoOrientation = videoOrientation
    }
  }
  
  func checkCameraPermission(doIfGranted completion: @escaping () -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      completion()
    case .denied:
      return
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { (granted) in
        if granted {
          completion()
        }
      }
    case .restricted:
      return
    }
  }
  
  func prepareCameraSession() {
    guard let backCamInput = backCameraInput,
      session.canAddInput(backCamInput),
      session.canAddOutput(photoOutput)
      else { return }
    session.beginConfiguration()
    session.sessionPreset = .photo
    session.addInput(backCamInput)
    session.addOutput(photoOutput)
    session.commitConfiguration()
    previewView.videoPreviewLayer.session = session
    session.startRunning()
    currentPosition = .back
  }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if let error = error {
      print("Error: \(error.localizedDescription)")
      return
    }
    if let imageRep = photo.cgImageRepresentation() {
      let orientation = photo.metadata[kCGImagePropertyOrientation as String] as! NSNumber
      let uiOrientation = UIImage.Orientation(CGImagePropertyOrientation(rawValue: orientation.uint32Value)!)
      let image = UIImage(cgImage: imageRep.takeUnretainedValue(), scale: 1, orientation: uiOrientation)
      let photo = Photo(image: image)
      self.performSegue(withIdentifier: "PhotoDetail", sender: photo)
    }
  }
}

