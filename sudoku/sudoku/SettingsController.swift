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
    static var settings = Settings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data:
        self.levelPicker.delegate = self
        self.levelPicker.dataSource = self
        
        // Input data into the Array:
        pickerData = ["EASY", "MEDIUM", "HARD"]
        
        if let i = pickerData.index(of: SettingsController.settings.level) {
            levelPicker.selectRow(i, inComponent: 0, animated: true)
        }
        
        musicSwitch.setOn(SettingsController.settings.music, animated: true)
        
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
        SettingsController.settings.level = pickerData[row]
    }
    
    @IBAction func musicSwitchToggle(_ sender: UISwitch) {
        if sender.isOn {
            SettingsController.settings.music = true
        } else {
            SettingsController.settings.music = false
        }
    }
    
}
