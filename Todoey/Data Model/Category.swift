//
//  Category.swift
//  Todoey
//
//  Created by Clovis Magenta da Cunha on 07/01/2019.
//  Copyright © 2019 CMC. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    var items = List<Item>()
}
