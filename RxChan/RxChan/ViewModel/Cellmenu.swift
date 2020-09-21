//
//  Cellmenu.swift
//  RxChan
//
//  Created by 임승혁 on 2020/09/10.
//  Copyright © 2020 임승혁. All rights reserved.
//

import Foundation

struct Cellmenu {
    var menuName: String
    var description: String
    
    init(_ item: Model) {
        self.menuName = item.body.title
        self.description = item.body.description
    }
    
    init(title: String, description: String) {
        self.menuName = title
        self.description = description
    }
}
