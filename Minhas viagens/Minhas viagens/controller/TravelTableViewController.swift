//
//  TravelTableViewController.swift
//  Minhas viagens
//
//  Created by Gilberto Silva on 15/02/21.
//

import UIKit

class TravelTableViewController: UITableViewController {
    private var travels: [Travel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTravels()
    }
    
    private func loadTravels() {
        self.travels = TravelRepository.shared.getAll()
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { travels.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentTravel = travels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "travelCell", for: indexPath)
        cell.textLabel?.text = currentTravel.title
        
        //Ocultando linha de separação dos items
        //cell.separatorInset = UIEdgeInsets(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0));
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentTravel = travels[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "mapTravel", sender: currentTravel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "mapTravel", let item = sender{
          let  travelMapViewController  = segue.destination as! TravelMapViewController
            travelMapViewController.travelSelected = item as? Travel
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let currentItem = travels[indexPath.row]
        if editingStyle == .delete {
            deleteCell(currentItem)
        }
    }
    private func deleteCell(_ currentItem: Travel) {
        let message = "Deseja deletar a viagem: \(currentItem.title)?"
        let positiveHandler:((UIAlertAction) -> Void)? = { (action) in
            let isSuccess = TravelRepository.shared.delete(travel: currentItem)
            if isSuccess {
                AlertHelper.shared.showMessage(viewController: self, message: "Viagem deletada com sucesso!")
                self.loadTravels()
            }else {
                AlertHelper.shared.showMessage(viewController: self, message: "Error ao deletar viagem!")
            }
        }
        AlertHelper.shared.showConfirmationMessage(viewController: self, message: message, positiveHandler: positiveHandler)
    }
    
}
