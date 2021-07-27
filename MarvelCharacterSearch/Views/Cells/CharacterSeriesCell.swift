//
//  CharacterSeriesCell.swift
//  MarvelCharacterSearch
//
//  Created by Raymond Donkemezuo on 7/25/21.
//

import UIKit

struct CharacterSeriesCellViewModel {
    var thumbnailPath: String
    var endedYear: String
    var startedYear: String
}

class CharacterSeriesCell: UICollectionViewCell {
    static let cellID = "CharacterSeriesCell"
    @IBOutlet weak var seriesImageView: UIImageView!
    @IBOutlet weak var startedYearLabel: UILabel!
    @IBOutlet weak var endedYearLabel: UILabel!
    
    var viewModel: CharacterSeriesCellViewModel? {
        didSet {
            guard let viewModel = viewModel else
            {
                return;
            }
            seriesImageView.kf.setImage(with: URL(string: viewModel.thumbnailPath), placeholder: UIImage(named: "placeHolder"))
            startedYearLabel.text = viewModel.startedYear
            endedYearLabel.text = viewModel.endedYear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

