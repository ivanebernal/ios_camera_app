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
  @IBOutlet weak var permissionLabel: UILabel!
  
  lazy var frontCameraInput: AVCaptureDeviceInput? = {
    if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front){
      do {
       return try AVCaptureDeviceInput(device: device)
      } catch {
        print("Unable to initialize front camera \(error.localizedDescription)")
        return nil
      }
    } else {
      return nil
    }
  } ()
  lazy var backCameraInput: AVCaptureDeviceInput? = {
    if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
      do {
        return try AVCaptureDeviceInput(device: device)
      } catch {
        print("Unable to initialize back camera \(error.localizedDescription)")
        return nil
      }
    } else { return nil }
  } ()
  let photoOutput = AVCapturePhotoOutput()
  let session = AVCaptureSession()
  var currentPosition: AVCaptureDevice.Position = .back
  
  override func viewDidLoad() {
    super.viewDidLoad()
    DemoClass.printHelloWorld()
    configureViews()
    checkCameraPermission(doIfGranted: prepareCameraSession, doIfError: {
      self.notifyPermissionError(cause: $0)
      self.enableCameraViews(enable: false)
    })
  }
  
  override func viewWillAppear(_ animated: Bool) {
    DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.session.startRunning()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.session.stopRunning()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let sender = sender as? UIImage,
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
  
  @objc private func flipCamera() {
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
  
  @objc private func capturePhoto() {
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
  
  private func checkCameraPermission(doIfGranted completion: @escaping () -> Void, doIfError error: @escaping (String) -> Void ) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      completion()
    case .denied:
      error("Camera access was denied.")
      return
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { (granted) in
        if granted {
          completion()
        } else {
          error("Camera access was denied.")
        }
      }
    case .restricted:
      error("Camera access is restricted.")
      return
    }
  }
  
  private func notifyPermissionError(cause errorString: String) {
    let alert = UIAlertController(title: "Camera permission error", message: errorString, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
  
  private func enableCameraViews(enable: Bool) {
    captureButton.isEnabled = enable
    flipCameraButton.isEnabled = enable
    permissionLabel.isHidden = enable
  }
  
  private func prepareCameraSession() {
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
      performSegue(withIdentifier: "PhotoDetail", sender: image)
    }
  }
}

