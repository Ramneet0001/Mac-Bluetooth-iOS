//
//  cellClassTableViewCell.swift
//  Mac-Bluetooth-iOS
//
//  Created by Ramneet on 04/05/20.
//  Copyright © 2020 Ramneet. All rights reserved.
//

import UIKit

class cellClassTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    @IBOutlet weak var name_lbl: UILabel!
    @IBOutlet weak var deviceStateLbl: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
