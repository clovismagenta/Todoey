//
//  ViewController.swift
//  Todoey
//
//  Created by Clovis Magenta da Cunha on 27/12/2018.
//  Copyright © 2018 CMC. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = ["Find Mike","Buy eggs","Go to Shopping","Study English"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // right button "+"
        let buttonAdd = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addItem))
        buttonAdd.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = buttonAdd
        
    }
    
    //MARK - Tableview datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        itemCell.textLabel?.text = itemArray[indexPath.row]
        
        return itemCell
        
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }


    //MARK - Add new items
    
    @objc func addItem() {
        
        var globalTextField = UITextField()
        
        let alertView = UIAlertController(title: "Add a new Todoey", message: "", preferredStyle: .alert)
        let actionAlert = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
            if let newItem = globalTextField.text {
                if newItem != "" {
                    self.itemArray.append(newItem)
                }
            }
            
            self.updateUIList()
        }
        
        alertView.addAction(actionAlert)
        alertView.addTextField { (alertTextField) in
            alertTextField.placeholder = "Inform your new Todoey item..."
            globalTextField = alertTextField
        }
        
        present(alertView, animated: true, completion: nil)
    }
    
    
    //MARK - Update UI
    
    func updateUIList() {
        tableView.reloadData()
    }
}

