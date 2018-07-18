//
//  ViewController.swift
//  AdvertisementView
//
//  Created by lisilong on 01/06/2018.
//  Copyright (c) 2018 lisilong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView.init(image: UIImage.init(named: "view_bg_image.png"))
        imageView.frame = self.view.bounds
        self.view.addSubview(imageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

