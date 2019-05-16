//
//  GerritService.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/2/7.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa
import Alamofire
import ObjectMapper

class GerritService {
    private let baseUrl = "http://gerrit.zhenguanyu.com"

    private let user: String!
    private let password: String!

    init(user: String, password: String) {
        self.user = user
        self.password = password
    }

    func verifyAccount(_ completion: @escaping (String?, Int?) -> Void) {
        let url = baseUrl + "/a/accounts/self/name"
        Alamofire.request(url).authenticate(user: user, password: password).responseData { response in
            let statusCode = response.response?.statusCode
            switch response.result {
            case .success(_):
                guard let name = GerritResponseUtils.filterResponse(response.data) else {
                    completion(nil, statusCode)
                    return
                }
                completion(name, statusCode)
                break
            case .failure(_):
                completion(nil, statusCode)
                break
            }
        }
    }

    func fetchReviewList(_ completion: @escaping ([Change]?) -> Void) {
        // 具体见 https://gerrit-review.googlesource.com/Documentation/user-search.html#_search_operators
        let query = "?q=(status:open+is:owner)OR(status:open+is:reviewer)&o=MESSAGES&o=DETAILED_ACCOUNTS"
        let url = baseUrl + "/a/changes/" + query
        Alamofire.request(url).authenticate(user: user, password: password).responseData { response in
            switch response.result {
            case .success(_):
                guard let jsonString = GerritResponseUtils.filterResponse(response.data),
                    let changes = Mapper<Change>().mapArray(JSONString: jsonString) else {
                        completion(nil)
                        return
                }
                completion(changes)
                break
            case .failure(_):
                completion(nil)
                break
            }
        }
    }

    func fetchChangeDetail(changeId: String, completion: @escaping ((Change?) -> Void)) {
        let url = baseUrl + "/a/changes/" + "\(changeId)/detail"
        Alamofire.request(url).authenticate(user: user, password: password).responseData { response in
            switch response.result {
            case .success(_):
                guard let jsonString = GerritResponseUtils.filterResponse(response.data),
                    let change = Mapper<Change>().map(JSONString: jsonString) else {
                        completion(nil)
                        return
                }
                completion(change)
                break
            case .failure(_):
                completion(nil)
                break
            }
        }
    }

}
