//
//  MenuController.swift
//  sudoku
//
//  Created by Gautam on 10/23/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit

class MenuController: UIViewController, UIPopoverPresentationControllerDelegate {
    
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
    
    @IBAction func exitButton(_ sender: UIButton) {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue"{
            let dest = segue.destination
            if let pop = dest.popoverPresentationController{
                pop.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBAction func settingsButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "settingsSegue", sender: self)
    }
}
