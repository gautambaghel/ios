//
//  MenuController.swift
//  sudoku
//
//  Created by Gautam on 10/23/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit

class MenuController: UIViewController {

    @IBOutlet weak var background: UIImageView!
    
    override func viewDidLoad() {
        animate(background)
    }
    
    func animate(_ image: UIImageView) {
        UIView.animate(withDuration: 8, delay: 0, options: .curveLinear, animations: {
            image.transform = CGAffineTransform(translationX: -100, y: -100)
        }) { (success: Bool) in
            image.transform = CGAffineTransform.identity
            self.animate(image)
        }
    }
    
}
