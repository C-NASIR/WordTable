//
//  DetailTableViewController.swift
//  WordTable
//
//  Created by Abdinasir Muhumed on 12/7/19.
//  Copyright © 2019 Nasir. All rights reserved.
//

import UIKit
import CoreData
class DetailTableViewController: UITableViewController {
    var appdelegate : AppDelegate!
    private var query = ""
    var persistentContainer : NSPersistentContainer!
    private let toAddDetailViewControllerSegue = "toAddDetailViewControllerSegue"
    private let toUpdateViewControllerSegue = "toUpdateViewControllerSegue"
    var department : Department!
        @IBOutlet weak var EditButton: UIBarButtonItem!
    private var fetchTermsRC : NSFetchedResultsController<Term>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = department.name
        refresh()
    }
    private func refresh(){
        let termsRequest = Term.fetchRequest() as NSFetchRequest<Term>
        if query.isEmpty {
          termsRequest.predicate  = NSPredicate(format: "(department = %@)", department)
        }else {
            termsRequest.predicate = NSPredicate(format: "english CONTAINS[cd] %@ AND department = %@", query,department)
        }
        let termSort = NSSortDescriptor(key: "english", ascending: true)
                
        termsRequest.sortDescriptors = [termSort]
        
        fetchTermsRC = NSFetchedResultsController(fetchRequest: termsRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchTermsRC.delegate = self
        do {
            try fetchTermsRC.performFetch()
            if department.name == "Pediatrics" && fetchTermsRC.fetchedObjects?.count == 0{
                loadingInitialPedTerms()
                try fetchTermsRC.performFetch()
            }
        } catch let error as NSError {
            print("Couldn't fetch data \(error), \(error.userInfo)")
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchTermsRC.fetchedObjects?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailTableViewCell
       configureCell(cell, at: indexPath)
        return cell
    }
    
    func configureCell(_ cell : DetailTableViewCell, at indexPath : IndexPath){
        let item = fetchTermsRC.object(at: indexPath)
        cell.englishLabel.text = item.english
        cell.descriptionLabel.text = item.termdescription
        cell.somaliLabel.text = item.somali
        cell.hmongLabel.text = item.hmong
        cell.spanishLabel.text = item.spanish
    }
    
    //MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let term = fetchTermsRC.object(at: indexPath)
            persistentContainer.viewContext.delete(term)
            appdelegate.saveContext()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let term = fetchTermsRC.object(at: sourceIndexPath)
        term.priority = 1
        appdelegate.saveContext()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toAddDetailViewControllerSegue {
            callAddDetailViewController(segue)
        } else if segue.identifier == toUpdateViewControllerSegue {
            guard let indexPath = getAccessorsIndexPathFromTheCell(sender: sender) else { return }
            callUpdateDetailViewController(segue, indexPath: indexPath)
        }
    }
    
    //MARK: - Private Methods
    private func callUpdateDetailViewController(_ segue : UIStoryboardSegue, indexPath : IndexPath) {
        guard let updateVC = getManupulateDetailUITableViewController(segue) else { return }
        updateVC.term = fetchTermsRC.object(at: indexPath)
        updateVC.delegate = self
    }
    
    private func callAddDetailViewController(_ segue : UIStoryboardSegue) {
        guard let addDetailVC = getManupulateDetailUITableViewController(segue) else { return }
        addDetailVC.department = department
        addDetailVC.appDelegate = appdelegate
        addDetailVC.persistentContainer = persistentContainer
    }
    
    private func getManupulateDetailUITableViewController(_ segue : UIStoryboardSegue) -> ManupulateDetailUITableViewController? {
        guard let nav = segue.destination as? UINavigationController else { return nil }
        guard let updatedVC = nav.viewControllers.first as? ManupulateDetailUITableViewController else { return nil}
        return updatedVC
    }
    
    private func getAccessorsIndexPathFromTheCell(sender : Any?) -> IndexPath?{
        guard let cell = sender as? UITableViewCell else { return nil}
        let indexPath = tableView.indexPath(for: cell)
        return indexPath
    }
    
    //MARK: Only for initial loading of PediatricTerms
    private func loadingInitialPedTerms(){
        if department.name == "Pediatrics" {
            let termsDic = wordsList().Pterms
            for (english,terms) in  termsDic {
                let term = Term(context: persistentContainer.viewContext)
                print(english)
                term.english = english
                term.termdescription = terms[Languages.English]
                term.spanish = terms[Languages.Spanish]
                term.somali = terms[Languages.Somali]
                term.hmong = terms[Languages.Hmong]
                term.department = department
                appdelegate.saveContext()
            }
        }
    }
}

extension DetailTableViewController : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete :
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update :
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                guard let cell = cell as? DetailTableViewCell else { return }
                configureCell(cell, at: indexPath)
            }
        case .move :
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension DetailTableViewController : UpdateDetailViewControllerDelegate {
    func ManupulateDetailUITableViewController(_ controller: ManupulateDetailUITableViewController, didFinishAddingTerm term: Term, department dept: Department, values: [String : String]) {
        term.english = values["name"]!
        term.termdescription = values["description"]!
        term.spanish = values["spanish"]!
        term.somali = values["somali"]!
        term.hmong = values["hmong"]!
        term.department = dept
        appdelegate.saveContext()
    }
}

extension DetailTableViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        query = text
        refresh()
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        query = ""
        searchBar.text = nil
        searchBar.resignFirstResponder()
        refresh()
        tableView.reloadData()
    }
}
