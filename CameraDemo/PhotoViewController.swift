//
//  PhotoViewController.swift
//  CameraDemo
//
//  Created by Ivan Esparza on 2/6/19.
//  Copyright © 2019 ivanebernal. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
  @IBOutlet weak var imageView: UIImageView!
  
  var image: UIImage?
  
  override func viewWillAppear(_ animated: Bool) {
    imageView.image = image
  }
}
