//
//  TableViewCell.swift
//  DivvyFindr
//
//  Created by Matt Deuschle on 2/5/16.
//  Copyright © 2016 Matt Deuschle. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var numberOfBikes: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
