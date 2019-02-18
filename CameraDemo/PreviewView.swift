//
//  PreviewView.swift
//  CameraDemo
//
//  Created by Ivan Esparza on 2/6/19.
//  Copyright © 2019 ivanebernal. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {

  override class var layerClass: AnyClass {
    return AVCaptureVideoPreviewLayer.self
  }
  
  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    return layer as! AVCaptureVideoPreviewLayer
  }

}
