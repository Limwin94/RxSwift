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
    let cellID = "MenuTableViewCell"
    
    // MARK: - IBOutlet
    @IBOutlet weak var menuTableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.dataSource = self
        menuTableView.delegate = self
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
}



