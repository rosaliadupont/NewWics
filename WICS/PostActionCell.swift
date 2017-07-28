//
//  PostActionCell.swift
//  WICS
//
//  Created by Rosalia Dupont on 7/19/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit

protocol PostActionCellDelegate: class {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell)
}


class PostActionCell: UITableViewCell {
    
    // MARK: - Properties
    weak var delegate: PostActionCellDelegate?
    
    static let height: CGFloat = 46
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    // MARK: - IBActions
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.didTapLikeButton(sender, on: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
    
}






