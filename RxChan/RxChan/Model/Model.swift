//
//  Model.swift
//  RxChan
//
//  Created by 임승혁 on 2020/09/10.
//  Copyright © 2020 임승혁. All rights reserved.
//

import Foundation

struct Model: Codable {
    let statusCode: Int
    let body: ModelBody
}

struct ModelBody: Codable {
    let detail_hash: String
    let image: String
    let alt: String
    let delivery_type: [String]
    let title: String
    let description: String
    let n_price: String
    let s_price: String
    let badge: [String]
}
