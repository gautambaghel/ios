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
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data:
        self.levelPicker.delegate = self
        self.levelPicker.dataSource = self
        
        // Input data into the Array:
        pickerData = ["EASY", "MEDIUM", "HARD"]
        
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
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
    
}
