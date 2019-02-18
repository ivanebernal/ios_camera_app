//
//  PhotoViewController.swift
//  CameraDemo
//
//  Created by Ivan Esparza on 2/6/19.
//  Copyright © 2019 ivanebernal. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
  
  static var name = String(describing: PhotoViewController.self)
  
  @IBOutlet weak var imageView: UIImageView!
  
  var image: Photo?
  
  override func viewWillAppear(_ animated: Bool) {
    imageView.image = image?.image
  }
}
