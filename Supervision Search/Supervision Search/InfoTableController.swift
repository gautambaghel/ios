//
//  InfoTableController.swift
//  Supervision Search
//
//  Created by Gautam on 12/1/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit

class InfoTableController: UITableViewController {
    
    var infoContent = [InfoContent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadButtonInfos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoContent.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ButtonInfoCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ButtonInfoCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let infoData = infoContent[indexPath.row]
        
        cell.nameLabel.text = infoData.heading
        cell.photoImageView.image = infoData.image
        cell.descriptionLabel.text = infoData.desc
        
        return cell
    }
    
    @IBAction func exit(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func loadButtonInfos() {
        
        let images = [#imageLiteral(resourceName: "find"),#imageLiteral(resourceName: "plus"),#imageLiteral(resourceName: "minus"),#imageLiteral(resourceName: "info"),#imageLiteral(resourceName: "microphone"),#imageLiteral(resourceName: "camera"),#imageLiteral(resourceName: "right-arrow"),#imageLiteral(resourceName: "left-arrow"),#imageLiteral(resourceName: "zoom"),#imageLiteral(resourceName: "retry")]
        let headings = ["Scan","Zoom in","Zoom out","Info","Microphone","Camera","Navigate left","Navigate right","Focus","Retry"]
        let descriptions = ["Press this button to take picture and scan the image for object of interest",
                            "Sliding the seek bar towards the plus symbol will zoom the camera lens",
                            "Sliding the seek bar towards the minus symbol will give a wider view",
                            "Opens the info panel for more help",
                            "Speech recognition and microphone access is required to speak keywords",
                            "Use this to retake the picture if the searched keyword is not found",
                            "On finding multiple keywords this button will navigate to the previous word",
                            "On finding multiple keywords this button will navigate to the next word",
                            "Shown when a single keyword is found, press this to zoom in",
                            "If the internet is slow or if servers are slow use this to send data again"]
        
        for i in 0..<images.count {
            infoContent.append(InfoContent(heading: headings[i].uppercased(), image: images[i], desc: descriptions[i]))
        }
    }
}


class InfoContent {
    var heading: String
    var image: UIImage
    var desc: String
    
    init(heading: String, image: UIImage, desc: String){
        self.heading = heading
        self.image = image
        self.desc = desc
    }
}
