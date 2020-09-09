//
//  ViewController.swift
//  RxChan
//
//  Created by 임승혁 on 2020/09/09.
//  Copyright © 2020 임승혁. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ViewController: UIViewController {
    // MARK: - Properties
    let viewModel = MenuViewModel()
    let disposeBag = DisposeBag()
    
    // MARK: - IBOutlet
    @IBOutlet weak var menuTableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        bindTableView()
    }
    
    private func bindTableView() {
        viewModel.menuObservable
            .observeOn(MainScheduler.instance)
            .bind(to: menuTableView.rx.items(cellIdentifier: MenuTableViewCell.identifier,
                                             cellType: MenuTableViewCell.self)) { _, item, cell in
                                                
                                                cell.menuLabel.text = item.menuName
                                                
        }.disposed(by: disposeBag)
    }
}
