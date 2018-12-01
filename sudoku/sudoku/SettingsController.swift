//
//  SettingsController.swift
//  sudoku
//
//  Created by Gautam on 10/24/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit

class SettingsController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var levelPicker: UIPickerView!
    @IBOutlet weak var musicSwitch: UISwitch!
    
    private var pickerData: [String] = [String]()
    private var settings = Settings()
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        self.saveSettings()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data:
        self.levelPicker.delegate = self
        self.levelPicker.dataSource = self
        
        // Input data into the Array:
        pickerData = ["EASY", "MEDIUM", "HARD"]
        
        let preferences = UserDefaults.standard
        let continueGameKey = "settings"
        if let settingsData = preferences.string(forKey: continueGameKey) {
            self.settings.set(settingsString: settingsData)
        }
        
        if let i = pickerData.index(of: settings.level) {
            levelPicker.selectRow(i, inComponent: 0, animated: true)
        }
        
        musicSwitch.setOn(settings.music, animated: true)
        
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if ((view as? UILabel) != nil) {
            label = view as! UILabel
        } else {
            label = UILabel()
        }
        
        label.font = UIFont(name: "Papyrus", size: 17.0)
        label.text = pickerData[row]
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        settings.level = pickerData[row]
    }
    
    @IBAction func musicSwitchToggle(_ sender: UISwitch) {
        if sender.isOn {
            settings.music = true
        } else {
            settings.music = false
        }
    }
    
    func saveSettings(){
        let preferences = UserDefaults.standard
        let continueGameKey = "settings"
        
        preferences.set(settings.toString(), forKey: continueGameKey)
        //  Save to disk
        preferences.synchronize()
    }
    
}
