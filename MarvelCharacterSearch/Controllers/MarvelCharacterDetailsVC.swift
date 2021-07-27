//
//  MarvelCharacterDetailsViewModel.swift
//  MarvelCharacterSearch
//
//  Created by Raymond Donkemezuo on 7/25/21.
//

import UIKit
import CoreData

struct MarvelCharacterDetailsViewModel {
    var thumbnailPath: String
    var characterName: String
    var characterBio: String
    var defaultMessage = "Information not available at this time"
    var id: Int
    var characterDescription: String {
        return characterBio.isEmpty ? defaultMessage : characterBio
    }
    var emptyBio: Bool {
        return characterDescription == defaultMessage
    }
}

class MarvelCharacterDetailsVC: UIViewController {
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var characterBioTextView: UITextView!
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    var viewModel: MarvelCharacterDetailsViewModel?
    private let dataManager = DataManager()
    
    private lazy var coreDataFetchController: NSFetchedResultsController<CharacterSeries> = {
        let fetchRequest = NSFetchRequest<CharacterSeries>(entityName: CharacterSeries.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "seriesID", ascending: true)]
        let predicate = NSPredicate(format: "characterID == %ld", (viewModel?.id ?? 0))
        fetchRequest.predicate = predicate
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataManager.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        adjustUITextViewHeight()
        fetchSeriesFromCharacter(_: false)
        registerCell()
        registerDelegates()
    }
    
    /// - TAG: A method to register tableView cell
    private func registerCell() {
        seriesCollectionView.register(UINib(nibName: CharacterSeriesCell.cellID, bundle: nil), forCellWithReuseIdentifier: CharacterSeriesCell.cellID)
    }
    
    /// - TAG: A method to register delegate
    private func registerDelegates() {
        seriesCollectionView.dataSource = self
        seriesCollectionView.delegate = self
    }
    
    /// - TAG: A method to setup UI
    private func setupUI() {
        guard let viewModel = viewModel else
        {
            return;
        }
        characterImageView?.kf.setImage(with: URL(string: viewModel.thumbnailPath), placeholder: UIImage(named: "placeHolder"))
        characterBioTextView.text = viewModel.characterDescription
        title = viewModel.characterName
        if (coreDataFetchController.fetchedObjects?.isEmpty ?? true) {
            self.emptyStateLabel.isHidden = false
            self.seriesCollectionView.isHidden = true
        }
    }
    
    /// - TAG: Set's the height of the TextView according to it's context
    func adjustUITextViewHeight()
    {
        characterBioTextView.sizeToFit()
        let contextHeight = characterBioTextView.contentSize.height
        textViewHeight.constant = contextHeight
        characterBioTextView.translatesAutoresizingMaskIntoConstraints = false
        characterBioTextView.isScrollEnabled = false
        if (viewModel?.emptyBio ?? true){
            characterBioTextView.textAlignment = .center
        }
    }
    /// - TAG: A method to fetch current charater series
    private func fetchSeriesFromCharacter(_ fetchNextBatch: Bool = false){
        guard let characterID = viewModel?.id else
        {
            return;
        }
        dataManager.fetchSeriesByCharacterFromApi(fetchNextBatch , characterID) { (error) in
            if let error = error {
                self.showAlert(title: "Unexpected error encountered", message: error.errorMessage.userError)
            } else {
                self.updateAndReloadUI()
            }
        }
    }
    
    /// - TAG: A method to update UI when core data objects gets updated
    private func updateAndReloadUI() {
        if (self.coreDataFetchController.fetchedObjects?.isEmpty ?? true) {
            self.emptyStateLabel.isHidden = false
            self.seriesCollectionView.isHidden = true
        } else {
            self.emptyStateLabel.isHidden = true
            self.seriesCollectionView.isHidden = false
            DispatchQueue.main.async {
                self.seriesCollectionView.reloadData()
            }
        }
    }
}

extension MarvelCharacterDetailsVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coreDataFetchController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let series = coreDataFetchController.object(at: indexPath)
        guard let seriesCell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterSeriesCell.cellID, for: indexPath) as? CharacterSeriesCell else
        {
            return UICollectionViewCell()
        }
        let viewModel = CharacterSeriesCellViewModel(thumbnailPath: series.imageString, endedYear: series.endYearString, startedYear: series.startYearString)
        seriesCell.viewModel = viewModel
        return seriesCell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == ((coreDataFetchController.fetchedObjects?.count ?? 0) - 3) &&
            dataManager.numberOfCharacterSeriesFetched < dataManager.totalSeriesForCharacter {
            self.fetchSeriesFromCharacter(_: true)
        }
    }
}

extension MarvelCharacterDetailsVC: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        self.updateAndReloadUI()
    }
}

