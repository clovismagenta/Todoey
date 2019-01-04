//
//  ViewController.swift
//  Todoey
//
//  Created by Clovis Magenta da Cunha on 27/12/2018.
//  Copyright © 2018 CMC. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [ Item ]()
    let defaults = UserDefaults()
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let actualContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        // right button "+"
        let buttonAdd = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addItem))
        
        buttonAdd.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = buttonAdd
        
//        if let takeList = defaults.array(forKey: "ToDoList") as? [Item] {
//            itemArray = takeList
//        }
        
    }
    
    //MARK: Tableview datasource Methods
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

    //MARK: Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
//        actualContext.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        tableView.deselectRow(at: indexPath, animated: true)
        saveItems()
    }


    //MARK: Add new items
    
    @objc func addItem() {
        
        var globalTextField = UITextField()
        
        let alertView = UIAlertController(title: "Add a new Todoey", message: "", preferredStyle: .alert)
        let actionAlert = UIAlertAction(title: "Confirm", style: .default) {
            (action) in
  
            let newItem = Item(context: self.actualContext)
        
            newItem.title = globalTextField.text!
            if newItem.title != "" {
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
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
    
    
    //MARK: Update UI
    
    func updateUIList() {
        tableView.reloadData()
    }
    
    func saveItems() {
//        let encoder = PropertyListEncoder()
        
        do {
//            let data = try encoder.encode(itemArray)
//            try data.write(to: dataFilePath!)
            try actualContext.save()
            
        } catch {
            print("Error saving context, \(error)")
        }
        updateUIList()
    }

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil ) {

        let standardPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [standardPredicate, additionalPredicate] )
            
        } else {
            
            request.predicate = standardPredicate
        }
        
        do {
            itemArray = try actualContext.fetch(request)
        } catch {
            print("Error during fetch request process: \(error)")
        }
        
////        if let data = try? Data(contentsOf: dataFilePath!) {
////            let decoder = PropertyListDecoder()
//        do {
//
////                itemArray = try decoder.decode([Item].self, from: data)
//        } catch {
//            print("Error on deconding, \(error)")
//        }
    }
    
//    func initialLoad() {
//
//        let newFetch : NSFetchRequest<Item> = Item.fetchRequest()
//        let newPredicate = NSPredicate(format: "parentCategory = %@", (selectedCategory)!)
//
//        newFetch.predicate = newPredicate
//        loadItems(with: newFetch)
//        tableView.reloadData()
//    }
    
}

// MARK: Search Bar methods
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let myRequest : NSFetchRequest<Item> = Item.fetchRequest()
        
        if let textTipped = searchBar.text {
            
            if textTipped == "" {
                
                myRequest.predicate = NSPredicate(format: "title != ''")
                myRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                
                loadItems(with: myRequest)
                tableView.reloadData()

            } else {

                myRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@", textTipped)
                myRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                
                loadItems(with: myRequest)
    
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let myRequest : NSFetchRequest<Item> = Item.fetchRequest()
        
        if searchBar.text?.count != 0 {
            
            let myPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            myRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: myRequest, predicate: myPredicate)

            
        } else {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            
        }
        
        tableView.reloadData()
    }
}

