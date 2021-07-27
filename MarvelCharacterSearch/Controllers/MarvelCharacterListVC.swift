//
//  MarvelCharacterListVC.swift
//  MarvelCharacterSearch
//
//  Created by Raymond Donkemezuo on 7/25/21.
//

import UIKit
import CoreData

class MarvelCharacterListVC: UIViewController {
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var charactersListTV: UITableView!
    @IBOutlet weak var characterSearchBar: UISearchBar!
    let dataManager = DataManager()
    
    private lazy var coreDataFetchController: NSFetchedResultsController<MarvelCharacter> = {
        let fetchRequest = NSFetchRequest<MarvelCharacter>(entityName: MarvelCharacter.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending:true)]
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
        registerDelegates()
        registerCell()
        title = "Marvel Characters"
        charactersListTV.separatorStyle = .none
        fetchData()
    }
    
    /// - TAG: A method to fetch all the characters
    private func fetchData(fetchNextBatch: Bool = false) {
        dataManager.fetchCharactersFromApi(fetchNextBatch) { (error) in
            if let error = error {
                self.showAlert(title: "Error", message: "Error \(error.errorMessage.userError) while fetching data")
            }
        }
    }
    
    /// - TAG: A method to fetch searched character remote data
    ////  I am currently not using this function but I kept it to explain my intentions during the code walk through
    private func fetchSearchedCharacter(_ searchedText: String) {
        dataManager.fetchSearchedCharacterFromApi(searchedText) { (error) in
            if let error = error {
                print(error.errorMessage)
            } else {
                self.searchCharacter(_: searchedText)
            }
        }
    }
    
    /// - TAG: A method to register delegate
    private func registerDelegates() {
        charactersListTV.dataSource = self
        charactersListTV.delegate = self
        characterSearchBar.delegate = self
    }
    
    /// - TAG: A method to register tableView cell
    private func registerCell() {
        charactersListTV.register(UINib(nibName: MarvelCharacterTVCell.cellID, bundle: nil), forCellReuseIdentifier: MarvelCharacterTVCell.cellID)
    }
    
    /// - TAG: A method to fetch searched character
    private func searchCharacter(_ searchText: String) {
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        coreDataFetchController.fetchRequest.predicate = predicate
        do {
            try coreDataFetchController.performFetch()
            if (coreDataFetchController.fetchedObjects?.isEmpty ?? true) {
                emptyLabel.isHidden = false
                charactersListTV.isHidden = true
            } else {
                emptyLabel.isHidden = true
                charactersListTV.isHidden = false
                self.charactersListTV.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// - TAG: A method to clear search and reload table
    private func cancelSearch() {
        if coreDataFetchController.fetchRequest.predicate != nil {
            coreDataFetchController.fetchRequest.predicate = nil
            do {
                try coreDataFetchController.performFetch()
                self.emptyLabel.isHidden = true
                self.charactersListTV.isHidden = false
                self.charactersListTV.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

/// - TAG: Datasource
extension MarvelCharacterListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataFetchController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let marvelCharacter = coreDataFetchController.object(at: indexPath)
        guard let marvelCharacterTVCell = tableView.dequeueReusableCell(withIdentifier: MarvelCharacterTVCell.cellID, for: indexPath) as? MarvelCharacterTVCell else
        {
            return UITableViewCell()
        }
        let viewModel = MarvelCharacterTVCellViewModel(thumbnailPath: marvelCharacter.imagethumbnail, characterName: marvelCharacter.characterName)
        marvelCharacterTVCell.viewModel = viewModel
        marvelCharacterTVCell.viewProfilePressed = {
            self.showMarvelCharacterDetails(at: indexPath)
        }
        return marvelCharacterTVCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = tableView.frame.size.height / 2
        return height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == ((coreDataFetchController.fetchedObjects?.count ?? 0) - 3) &&
            dataManager.numberOfCharactersFetched < dataManager.totalNumberOfMarvelCharacters {
            self.fetchData(fetchNextBatch: true)
        }
    }
}

extension MarvelCharacterListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.cancelSearch()
            return;
        }
        self.searchCharacter(_: searchText)
    }
}

extension MarvelCharacterListVC {
    /// - TAG: A method to segue to the marvel character details view
    func showMarvelCharacterDetails(at indexPath: IndexPath) {
        let marvelCharacter = coreDataFetchController.object(at: indexPath)
        let viewModel = MarvelCharacterDetailsViewModel(thumbnailPath: marvelCharacter.imagethumbnail, characterName: marvelCharacter.characterName, characterBio: marvelCharacter.characterDescription, id: marvelCharacter.characterID)
        let detailsViewController = MarvelCharacterDetailsVC()
        detailsViewController.viewModel = viewModel
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}

extension MarvelCharacterListVC: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        charactersListTV.reloadData()
    }
}
