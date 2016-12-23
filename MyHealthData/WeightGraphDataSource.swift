//
//  WeightGraphDataSource.swift
//  MyHealthData
//
//  Created by Schappet, James C on 12/23/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import ResearchKit

class WeightGraphDataSource: NSObject, ORKGraphChartViewDataSource {
    
    func setPlotPoints ( values: [ Float ] ) -> Void {
        var myPlotPoints =   Array(repeating:Array(repeating:ORKRangedPoint(), count:10), count:2)
        

        var count = 0
        for  i: Float in values  {
            myPlotPoints[0][count] = ORKRangedPoint(value:  CGFloat(i))
            myPlotPoints[1][count] = ORKRangedPoint(value: CGFloat(count))
            
            //print("\(count)  \(i)")
            count += 1
        }
        
        self.plotPoints = myPlotPoints
    }
    var plotPoints =
        [
            [
                ORKRangedPoint(value: 200),
                ORKRangedPoint(value: 450),
                ORKRangedPoint(value: 500),
                ORKRangedPoint(value: 250),
                ORKRangedPoint(value: 300),
                ORKRangedPoint(value: 600),
                ORKRangedPoint(value: 300),
                ],
            [
                ORKRangedPoint(value: 100),
                ORKRangedPoint(value: 350),
                ORKRangedPoint(value: 400),
                ORKRangedPoint(value: 150),
                ORKRangedPoint(value: 200),
                ORKRangedPoint(value: 500),
                ORKRangedPoint(value: 400),
                ]
    ]
    
    // Required methods
    
    func graphChartView(_ graphChartView: ORKGraphChartView, pointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKRangedPoint {
        
        return plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, numberOfPointsForPlotIndex plotIndex: Int) -> Int {
        return plotPoints[plotIndex].count
    }
    
    // Optional methods
    
    // Returns the number of points to the graph chart view
    func numberOfPlotsInGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return plotPoints.count
    }
    
    // Sets the maximum value on the y-axis
    func maximumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        return 1000
    }
    
    // Sets the minimum value on the y-axis
    func minimumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        return 0
    }
    
    // Provides titles for x-axis
    func graphChartView(graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        switch pointIndex {
        case 0:
            return "Mon"
        case 1:
            return "Tue"
        case 2:
            return "Wed"
        case 3:
            return "Thu"
        case 4:
            return "Fri"
        case 5:
            return "Sat"
        case 6:
            return "Sun"
        default:
            return "Day \(pointIndex + 1)"
        }
    }
    
    // Returns the color for the given plot index
    func graphChartView(graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
        if plotIndex == 0 {
            return UIColor.purple
        } else {
            return UIColor.red
        }
    }
}
