//
//  MenuViewModel.swift
//  RxChan
//
//  Created by 임승혁 on 2020/09/10.
//  Copyright © 2020 임승혁. All rights reserved.
//

import Foundation
import RxSwift

class MenuViewModel {
    let menuObservable = BehaviorSubject<[Cellmenu]>(value: [])
    
    init() {
        // fetch해서 onNext해주는 걸로 변경.
        let mockMenu = [Cellmenu(menuName: "[미노리키친] 규동 250g"),
                        Cellmenu(menuName: "[빅마마의밥친구] 아삭 고소한 연근고기조림 250g"),
                        Cellmenu(menuName: "[소중한식사] 골뱅이무침 195g")]
        
        menuObservable.onNext(mockMenu)
    }
}
