//
//  ButtonInfoCell.swift
//  Supervision Search
//
//  Created by Gautam on 12/1/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit

class ButtonInfoCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
