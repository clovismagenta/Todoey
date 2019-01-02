//
//  ViewController.swift
//  Todoey
//
//  Created by Clovis Magenta da Cunha on 27/12/2018.
//  Copyright © 2018 CMC. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [ Item ]()
    let defaults = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // right button "+"
        let buttonAdd = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addItem))
        
        buttonAdd.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = buttonAdd
        
        if let takeList = defaults.array(forKey: "ToDoListArray") as? [Item] {
            itemArray = takeList
        }
        
    }
    
    //MARK - Tableview datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let actualItem = itemArray[indexPath.row]
        
        itemCell.textLabel?.text = actualItem.title
        
        itemCell.accessoryType = actualItem.done ? .checkmark : .none
        
        return itemCell
        
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
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
        let newItem = Item()
        
            newItem.title = globalTextField.text!
            if newItem.title != "" {
                self.itemArray.append(newItem)
                self.defaults.setValue(self.itemArray, forKey: "ToDoListArray")
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

