//
//  APIService.swift
//  RxChan
//
//  Created by 임승혁 on 2020/09/13.
//  Copyright © 2020 임승혁. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

enum EndPoints: String {
    case main = "https://h3rb9c0ugl.execute-api.ap-northeast-2.amazonaws.com/develop/baminchan/main"
    case soup = "https://h3rb9c0ugl.execute-api.ap-northeast-2.amazonaws.com/develop/baminchan/soup"
    case side = "https://h3rb9c0ugl.execute-api.ap-northeast-2.amazonaws.com/develop/baminchan/side"
}

enum APIServiceError: String, Error {
    case urlError = "URL 생성에 실패했습니다."
    case modelTypeCastingError = "값을 받아오는 도중 오류가 발생했습니다."
}

class APIService {
    // request 세부 설정을 위해 따로 빼놓음.
    static func request(url: String) -> URLRequest? {
        guard let url = URL(string: url) else { return nil }
        return URLRequest(url: url)
    }
    
    // fetch하는 부분을 Single로 작성.
    static func fetchEachMenu(url: String) -> Single<Model> {
        return Single<Model>.create { single in
            guard let request = self.request(url: url) else {
                single(.error(APIServiceError.urlError))
                return Disposables.create()
            }
            
            AF.request(request)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let jsonData):
                        guard let returnModelObject = jsonData as? Model else {
                            single(.error(APIServiceError.modelTypeCastingError))
                            return
                        }
                        single(.success(returnModelObject))
                    case .failure(let error):
                        single(.error(error))
                    }
            }
            
            return Disposables.create { AF.cancelAllRequests() }
        }
    }
}
