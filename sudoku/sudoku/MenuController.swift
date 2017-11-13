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
        
        let preferences = UserDefaults.standard
        let saveSettings = "saveSettings"
        
        if let settingsData = preferences.string(forKey: saveSettings) {
            applySettings(settingsData: settingsData)
        }
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
    
    func saveSettings () {
        
        let preferences = UserDefaults.standard
        let saveSettings = "saveSettings"
        
        preferences.set(SettingsController.settings.toString(), forKey: saveSettings)
        //  Save to disk
        preferences.synchronize()
    }
    
    func applySettings (settingsData data: String) {
        SettingsController.settings.set(settingsString: data)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveSettings()
    }
    
}
