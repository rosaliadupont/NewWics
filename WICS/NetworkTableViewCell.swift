//
//  NetworkTableViewCell.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/21/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

protocol NetworkTableViewCellDelegate: class {
    func didTapFollowButton(_ followButton: UIButton, on cell: NetworkTableViewCell)
}

class NetworkTableViewCell: UITableViewCell {

    weak var delegate: NetworkTableViewCellDelegate?
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        followButton.layer.borderColor = UIColor.lightGray.cgColor
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = 6
        followButton.clipsToBounds = true
        
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func followButtonTapped(_ sender: UIButton) {
         delegate?.didTapFollowButton(sender, on: self)
    }

}
