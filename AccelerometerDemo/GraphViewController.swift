//
//  GraphViewController.swift
//  AccelerometerDemo
//
//  Created by ナム Nam Nguyen on 5/28/17.
//  Copyright © 2017 Benjamin. All rights reserved.
//

import UIKit
import SwiftChart

@objc class GraphViewController: UIViewController {

    @IBOutlet var graphView: ScrollableGraphView?
    var data: [Double]?
    var labels: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareData()
        
        guard let data = data, let labels = labels else {
            return
        }
        graphView?.dataPointSpacing = 80
        graphView?.lineCurviness = 0.5
        graphView?.lineStyle = .smooth
        graphView?.referenceLinePosition = .left
        graphView?.set(data: data, withLabels: labels)
    }
    
    internal func prepareData() {
        let accelerationData = AppController.shared().all()
        data = accelerationData.map({ return fabs($0.data.x * 100.0) })
        labels = accelerationData.map({ return $0.time })
    }
    
    public func updateData( _ newData:[Acceleration], option barOption: Int) {
        data = newData.map({
            var value:Double = $0.data.x
            if(barOption == 1) {
                value = $0.data.y
            } else if(barOption == 2) {
                value = $0.data.z
            }
            return fabs(value * 100.0)
        })
        labels = newData.map({ return $0.time })
        guard let data = data, let labels = labels else {
            return
        }
        graphView?.set(data: data, withLabels: labels)
        graphView?.layoutSubviews()
        guard let width = graphView?.contentSize.width else { return }
        let endOffset = CGPoint(x: width - 800.0, y: 0)
        graphView?.setContentOffset(endOffset, animated: true)
    }
}
