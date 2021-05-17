//
//  ViewController.swift
//  Papaoutai_charts_try
//
//  Created by Lila Kelland on 2021-05-04.
//
//  DayChartView.swift
//  Papaoutai
//
//  Created by Lila Kelland on 2021-05-03.
//https://www.youtube.com/watch?v=5Jwlet8L84w
//https://www.youtube.com/watch?v=Zk5m7vIFBWI

//import FSCalendar
import UIKit
import Charts
import TinyConstraints
import Alamofire
import SwiftyJSON
import FSCalendar

struct DayChartServerData:Decodable{
    let minutes_per_hour: [String: Int]
    let average_for_week: Int
}

class DayChartViewController: UIViewController, ChartViewDelegate{
    var minutesPerHour: [String:Int] = [:]
    var weekAverage: Int = 0
    var user_id: String = "960"
    var title_text:String = ""
    
    var calendarView:FSCalendar = FSCalendar()
//    var titleView:UILabel
//    var chartView:UIView
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26)
        label.textAlignment = .center
        label.textColor = .black
        label.shadowOffset = CGSize(width: 0, height: -0.5)
        label.shadowColor = .systemGray5
        label.text = "Thursday, April 5"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCalendar()
//        addTitle()
        print(Date().timeIntervalSinceReferenceDate)
        getChartDataForSelectedDay(dateSelectedTimeStamp: Int(Date().timeIntervalSinceReferenceDate))//115599648)
        
    }
    
    func setUpCalendar() {
        view.addSubview(calendarView)
        calendarView.frame = CGRect(x:0,
                                y:0,
                                width: view.frame.size.width - 30,
                                height: view.frame.size.width - 30)
        calendarView.delegate = self
    }
    
//    func addTitle(){
//        var titleView: UIView
//        titleView.frame = CGRect(x:0,
//                                 y: view.frame.size.width,
//                                 width: view.frame.size.width,
//                                 height: 30
//                                )
//        view.addSubview(titleView)
//    }
    
    func getChartDataForSelectedDay(dateSelectedTimeStamp:Int)  {
        
        let parameters = ["user_id": self.user_id, "day_in_timestamp": dateSelectedTimeStamp] as [String : Any]
        
        AF.request("https://papaoutai-rest-api.herokuapp.com/dayChart", method: .post, parameters: parameters).responseData { response in
            switch response.result {
                case .failure(let error):
                    print(error)
                    debugPrint("Response: \(response)")
                case .success(let data):
                    do {
                        let dayChartServerData = try JSONDecoder().decode(DayChartServerData.self, from: data)
                        
                        self.minutesPerHour = dayChartServerData.minutes_per_hour
                        print(self.minutesPerHour)
                        self.weekAverage = dayChartServerData.average_for_week
                        print(self.weekAverage)
                        
                        self.createChart()
                    } catch let error {
                        print(error)
                }
            }
        }
    }

    
    private func createChart() {
        let limitLine = self.weekAverage
        
        
        
        

        
        let r = CGRect(x:0,
                   y:view.frame.size.width + 20,
                   width: view.frame.size.width - 30,
                   height: view.frame.size.width - 30)
        let barChart = BarChartView(frame: r)
        
        barChart.setScaleEnabled(true)
        barChart.drawBarShadowEnabled = false
        barChart.drawValueAboveBarEnabled = false
        barChart.fitBars = true
        barChart.drawGridBackgroundEnabled = false
        barChart.chartDescription?.enabled = false
    
        
        // configure the axis
        let xAxis = barChart.xAxis
        xAxis.setLabelCount(5, force: false)
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        
        barChart.leftAxis.enabled = false
        
        let rightAxis = barChart.rightAxis
        rightAxis.labelPosition = .outsideChart
        rightAxis.drawZeroLineEnabled = false
        rightAxis.axisMinimum = 0
        
        // configure legend
        let legend = barChart.legend
        legend.form = .circle
        
        // supply data
        var entries = [BarChartDataEntry]()
        
        for (key, value) in self.minutesPerHour {
            print("key: \(key), value \(value)")
            entries.append(BarChartDataEntry(x: Double(Int(key) ?? 0), y: Double(value)))
        }
        
        let set = BarChartDataSet(entries: entries, label: "Hourly Usage (minutes)")
        set.drawValuesEnabled = false

        let data = BarChartData(dataSet: set)
        barChart.data = data
            
        barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        //        set.colors = ChartColorTemplates.joyful()
        
       // Add limit line
        let weekAverage = ChartLimitLine(limit: Double(limitLine)) //, label: "Week Average")
        barChart.rightAxis.addLimitLine(weekAverage)

        // Add chart view
        view.addSubview(barChart)
        barChart.delegate = self
    }
}


extension DayChartViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at MonthPosition: FSCalendarMonthPosition){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        let formattedDate = dateFormatter.string(from: date)
        let selectedTimeStamp = Int(date.timeIntervalSince1970)
        
        self.getChartDataForSelectedDay(dateSelectedTimeStamp: selectedTimeStamp)
        
        let myAlert = UIAlertController(title: "Date tapped", message: "\(formattedDate) \(selectedTimeStamp)", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel)
        myAlert.addAction(dismiss)
        
        //present this alert
        present(myAlert, animated: true)
    }
}

