//
//  APIFunctions.swift
//  Papaoutai
//
//  Created by Lila Kelland on 2021-03-10.
//

import Foundation
import Alamofire

struct Note: Decodable {
    var id: Int = 123
    var startTime: Int
    var druation: Int
}

class APIFunctions {
    
//    var delegate: DataDelegate?
    
    static let functions = APIFunctions()
    
//    func fetchSessions() {
//
//        AF.request.("http://192.168.4.29:5000/fetch").response { response in
//
//            print(response.data)
//
//            let data = String(data: response.data, encoding: .utf8)
//
//            self.delegate?.updateArray(newArray: data!)
//        }
//    }
    
//    func addSession(date: String, title: String) {
//        
//        AF.request("192.168.4.29:5000/add", method: .post, encoding: URLEncoding.httpBody, headers: ["id": id, "startTime": startTime, "duration": duration]).responseJSON() {
//            response in
//        }
//        
//    }
    
}
