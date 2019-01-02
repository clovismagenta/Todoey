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
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // right button "+"
        let buttonAdd = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addItem))
        
        buttonAdd.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = buttonAdd
        
        loadItems()
        
//        if let takeList = defaults.array(forKey: "ToDoList") as? [Item] {
//            itemArray = takeList
//        }
        
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
        print(dataFilePath)
        saveItems()
    }


    //MARK - Add new items
    
    @objc func addItem() {
        
        var globalTextField = UITextField()
        
        let alertView = UIAlertController(title: "Add a new Todoey", message: "", preferredStyle: .alert)
        let actionAlert = UIAlertAction(title: "Confirm", style: .default) {
            (action) in
  
            let newItem = Item()
        
            newItem.title = globalTextField.text!
            if newItem.title != "" {
                self.itemArray.append(newItem)
                
                self.saveItems()
                
//                self.defaults.setValue(self.itemArray, forKey: "ToDoList")
            }
            
        }
        
        alertView.addAction(actionAlert)
        alertView.addTextField { (alertTextField)
            in
            alertTextField.placeholder = "Inform your new Todoey item..."
            globalTextField = alertTextField
        }
        
        present(alertView, animated: true, completion: nil)
    }
    
    
    //MARK - Update UI
    
    func updateUIList() {
        tableView.reloadData()
    }
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
            
        } catch {
            print("Error enconding item Array, \(error)")
        }
        updateUIList()
    }

    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error on deconding, \(error)")
            }
        
        }
    }
}

