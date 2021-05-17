//
//  GetChartData.swift
//  Papaoutai_charts_try
//
//  Created by Lila Kelland on 2021-05-05.
//
import Alamofire
import SwiftyJSON
import UIKit

struct DayChartData:Decodable{
    let minutes_per_hour: [String: Int]
    let average_for_week: [Int]
}
class DayUsage {
    var minutesPerHour: [String:Int] = [:]
    var weekAverage: [Int] = []
    
    func getChartDataForSelectedDay(dateSelectedTimeStamp:Int)  {
        
        let parameters = ["user_id": 960, "day": 115599648]//dateSelectedTimeStamp]
        
        AF.request("https://papaoutai-rest-api.herokuapp.com/dayChart", method: .post, parameters: parameters).responseData { response in
            switch response.result {
                case .failure(let error):
                    print(error)
                    debugPrint("Response: \(response)")
                case .success(let data):
                    do {
                        let dayChartData = try JSONDecoder().decode(DayChartData.self, from: data)
                        self.minutesPerHour = dayChartData.minutes_per_hour
                        print(self.minutesPerHour)
                        self.weekAverage = dayChartData.average_for_week
                        print(self.weekAverage)
                    } catch let error {
                        print(error)
                }
            }
        }
    }
}
