//
//  CongratulationsController.swift
//  sudoku
//
//  Created by Gautam Baghel on 11/29/18.
//  Copyright © 2018 Gautam. All rights reserved.
//

import UIKit
import FLAnimatedImage

class CongratsController: UIViewController {
    
    var message:String = "Thanks for playing!"

    @IBOutlet weak var congratsImage: FLAnimatedImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path1 : String = Bundle.main.path(forResource: "congrats", ofType: "gif")!
        let url = URL(fileURLWithPath: path1)
        let gifData = try? Data(contentsOf: url)
        congratsImage.animatedImage = try? FLAnimatedImage(animatedGIFData: gifData)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(segueToMainController))
        congratsImage.addGestureRecognizer(tapGesture)
        congratsImage.isUserInteractionEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.displayAfter2s()
        }
    }
    
    func displayAfter2s() {
        
        let refreshAlert = UIAlertController(title: title, message: self.message, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { (action: UIAlertAction!) in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController:ViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let navController = UINavigationController(rootViewController: viewController)
            self.present(navController, animated: true, completion: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: { (action: UIAlertAction!) in
            self.segueToMainController()
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageTapped(gesture: UIGestureRecognizer) {
        self.segueToMainController()
    }
    
    @objc func segueToMainController() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuController:MenuController = storyBoard.instantiateViewController(withIdentifier: "MenuController") as! MenuController
        self.present(menuController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
