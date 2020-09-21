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
//    let fetchMenus: AnyObserver<Void>
//    let allMenus: Observable<Cellmenu> 
//    
//    let disposeBag = DisposeBag()
    
    init() {
        let menus = BehaviorSubject<Cellmenu>(value: Cellmenu(title: "", description: ""))
        let fetching = PublishSubject<Void>()
        fetchMenus = fetching.asObserver()
        let aa = fetching.flatMap { APIService.fetchEachMenu(url: EndPoints.main.rawValue)
        }.map { model -> Cellmenu in
            return Cellmenu(model)
        }
        fetching
            .flatMap { APIService.fetchEachMenu(url: EndPoints.main.rawValue) }
            .map { model in
                Cellmenu(model)
            }
        .do(onNext: model )
            .do(onError: { err in menus.onError(err) })
            .subscribe(onNext: menus.onNext)
            .disposed(by: disposeBag)
        
        allMenus = menus
    }
}
