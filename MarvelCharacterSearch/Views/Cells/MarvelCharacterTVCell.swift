//
//  MarvelCharacterTVCell.swift
//  MarvelCharacterSearch
//
//  Created by Raymond Donkemezuo on 7/25/21.
//

import UIKit
import Kingfisher

struct MarvelCharacterTVCellViewModel {
    var thumbnailPath: String
    var characterName: String
}

class MarvelCharacterTVCell: UITableViewCell {
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    var viewProfilePressed:(() -> ())?
    
    static let cellID = "MarvelCharacterTVCell"
    
    var viewModel: MarvelCharacterTVCellViewModel? {
        didSet {
            guard let viewModel = viewModel else
            {
                return;
            }
            characterNameLabel.text = viewModel.characterName
            characterImageView.kf.setImage(with: URL(string: viewModel.thumbnailPath), placeholder: UIImage(named: "placeHolder"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.borderColor = #colorLiteral(red: 0, green: 0.5579682589, blue: 1, alpha: 1)
        containerView.layer.borderWidth = 2
    }
    
    @IBAction func viewProfilePressed(_ sender: Any) {
        if let block = viewProfilePressed {
            block()
        }
    }
}
