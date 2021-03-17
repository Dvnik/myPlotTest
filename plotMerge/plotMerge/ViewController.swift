

import UIKit
import CorePlot

class myPlotSwitch
{
    var name:String!
    var index:Int!
    var color:CGColor!
    var plot:CPTScatterPlot!
    var plotCtrl:UISwitch!
    
    @objc func onValueChange(_ sender: UISwitch!)
    {
        if plot != nil
        {
            let on = sender.isOn
            plot.isHidden = !on
        }
    }
}


class ViewController: UIViewController
{
    
    //MARK:- Outlet
    @IBOutlet weak var switchStack: UIStackView!
    @IBOutlet weak var hostingView: CPTGraphHostingView!
    
    //MARK:- Values
    let maxShow:Int = 6
    let dataPoints:Int = 20
    let plotKeyName:String = "plotName"
    let yValueMax:Double = 200.0
    
    var myPlotObj:[myPlotSwitch]!
    var plotDatas:[ChartData]!
    var markerAnnotation:CPTPlotSpaceAnnotation!
    
    //MARK:- UIInit
    func initUIView()
    {
        createObjects()
        generateData()
    }
    // 產生控制元件
    func createObjects()
    {
        myPlotObj = [myPlotSwitch]()
        
        for i in 0..<Int.random(in: 1...maxShow)
        {
            let setItem = myPlotSwitch()
            setItem.name = "test_\(i)"
            setItem.index = i
            setItem.color = CGColor(red: CGFloat(Float.random(in: 0...1)),
                                    green: CGFloat(Float.random(in: 0...1)),
                                    blue: CGFloat(Float.random(in: 0...1)),
                                    alpha: 1)
            let newSwitch = UISwitch()
            newSwitch.isOn = true
            newSwitch.onTintColor = UIColor(cgColor: setItem.color)
            newSwitch.addTarget(setItem, action: #selector(setItem.onValueChange(_:)), for: .valueChanged)
            setItem.plotCtrl = newSwitch
            switchStack.addArrangedSubview(setItem.plotCtrl)
            // base plot
            setItem.plot = createScatterPlot(lineColor: setItem.color, plotID: setItem.name)
            // add object
            myPlotObj.append(setItem)
        }
    }
    // 產生資料
    func generateData()
    {
        plotDatas = [ChartData]()
        
        for _ in 0..<dataPoints
        {
            var myRates = [String:NSNumber]()
            myPlotObj.forEach { (item) in
                myRates[item.name] = NSNumber(value: Double.random(in: 10.0...200.0))
            }
            // Create Date
            var dateComponents = DateComponents()
            dateComponents.month  = Int.random(in: 1...12)
            dateComponents.day    = Int.random(in: 1...31)
            dateComponents.year   = Int.random(in: 2010...2030)
            dateComponents.hour   = Int.random(in: 1...24)
            // 宣告一個公曆，並將DateComponents指定的日期轉換成Date()物件
            let gregorian = Calendar(identifier: .gregorian)
            
            plotDatas.append(ChartData(date: gregorian.date(from: dateComponents) ?? Date(), rates: myRates ))
        }
        
    }
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUIView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        initPlot()
    }
    
    //MARK:- Plot
    func initPlot()
    {
        // 設定圖表
        configureGraph()
        // 設定軸線
        configureAxes()
        // 設定畫在圖表上的線
        configureChart()
    }
    
    func configureGraph()
    {
        // 指定graph 到hostView上
        let graph = CPTXYGraph(frame: hostingView.bounds)
        graph.plotAreaFrame?.masksToBorder = false
        hostingView.hostedGraph = graph
        //設定graph樣式
        graph.apply(CPTTheme(named: CPTThemeName.plainWhiteTheme))//主題
        graph.fill = CPTFill(color: CPTColor.clear())// 背景透明
        //調整圖表的畫面位置
        graph.paddingBottom = 30.0
        graph.paddingLeft = 35.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0
        // 設定標題
        setGraphTitle(setGraph: graph, name: "Merge Plot")
        // 設定範圍
        setGraphPlotSpace(setGraph: graph)
    }
    
    func configureAxes()
    {
        guard let axisSet = hostingView.hostedGraph?.axisSet as? CPTXYAxisSet else { return }
        // 軸線樣式
        let axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineWidth = 2.0
        axisLineStyle.lineColor = CPTColor.black()
        // x
        if let x = axisSet.xAxis
        {
            x.labelingPolicy = .none
            x.majorIntervalLength = 1
            x.axisLineStyle = axisLineStyle
            // Botton Text
            var majorTickLocations = Set<NSNumber>()
            var axisLabels = Set<CPTAxisLabel>()
            for (idx, data) in plotDatas.enumerated() {
                majorTickLocations.insert(NSNumber(value: idx))
                
                let label = CPTAxisLabel(text: "\(data.formatDate(format: nil))", textStyle: CPTTextStyle())
                label.tickLocation = NSNumber(value: idx)
                label.offset = 5.0
                label.alignment = .left
                axisLabels.insert(label)
            }
            x.majorTickLocations = majorTickLocations
            x.axisLabels = axisLabels
//            x.labelRotation = CGFloat(Double.pi / 4)
        }
        // y
        if let y = axisSet.yAxis
        {
            let majorTickLineStyle = CPTMutableLineStyle()
            majorTickLineStyle.lineColor = CPTColor.black().withAlphaComponent(0.1)
            let minorTickLineStyle = CPTMutableLineStyle()
            minorTickLineStyle.lineColor = CPTColor.black().withAlphaComponent(0.05)
            
            y.labelingPolicy = .automatic
            y.labelOffset = -10.0
            y.minorTicksPerInterval = 3
            y.majorTickLength = 30
            
            y.majorTickLineStyle = majorTickLineStyle
            y.minorTickLineStyle = minorTickLineStyle
            y.axisLineStyle = axisLineStyle
            y.majorIntervalLength = 1
            // 固定軸線位置，不會因為圖表移動的時候文字跟著走
            y.axisConstraints = CPTConstraints(relativeOffset: 0.0)
        }
        // line
        let blueLineStyle = CPTMutableLineStyle()
        blueLineStyle.lineColor = CPTColor.blue()
        blueLineStyle.lineWidth = 2
        blueLineStyle.dashPattern = [5, 5]
        
        let iAxis = CPTXYAxis(frame: CGRect.zero)
        iAxis.title          = nil
        iAxis.labelFormatter = nil
        iAxis.axisLineStyle  = blueLineStyle
        
        iAxis.coordinate = CPTCoordinate.Y
        iAxis.plotSpace = hostingView.hostedGraph?.defaultPlotSpace
        iAxis.majorTickLineStyle = nil
        iAxis.minorTickLineStyle = nil
        iAxis.orthogonalPosition = 0.0
        iAxis.isHidden = true
        // 加入
        axisSet.axes?.append(iAxis)
    }
    
    func configureChart()
    {
        guard let graph = hostingView.hostedGraph else { return }
        myPlotObj.forEach { (item) in
            // 將先前生成好的plot資訊加入到graph中
            if item.plot != nil
            {
                item.plot.dataSource = self
                item.plot.delegate = self
                graph.add(item.plot, to: graph.defaultPlotSpace)
            }
        }
        
        // annotation
        if let defSpace = graph.defaultPlotSpace
        {
            // 藍線樣式，和設定axes相同
            let blueLineStyle = CPTMutableLineStyle()
            blueLineStyle.lineColor = CPTColor.blue()
            blueLineStyle.lineWidth = 2
            blueLineStyle.dashPattern = [5, 5]
            // 註解(Annotation)文字樣式
            let hitAnnotationTextStyle = CPTMutableTextStyle()
            hitAnnotationTextStyle.color = CPTColor.black()
            hitAnnotationTextStyle.fontName = "Helvetica-Bold"
            hitAnnotationTextStyle.fontSize = 10
            // 顯示註解文字
            let textLayer = CPTTextLayer(text: "Annotation", style: hitAnnotationTextStyle)
            textLayer.borderLineStyle = blueLineStyle
            textLayer.fill = CPTFill(color: CPTColor.white())
            textLayer.cornerRadius = 3.0
            textLayer.paddingLeft     = 2.0
            textLayer.paddingTop      = 2.0
            textLayer.paddingRight    = 2.0
            textLayer.paddingBottom   = 2.0
            textLayer.isHidden          = true

            // 指定註解到graph上
            let annotation = CPTPlotSpaceAnnotation(plotSpace: defSpace, anchorPlotPoint: [0, 0])
            annotation.contentLayer = textLayer
            graph.addAnnotation(annotation)
            self.markerAnnotation = annotation//同時指定到class的相同型別變數
        }
    }
    
    // 設定圖表的顯示範圍
    func setGraphPlotSpace(setGraph graph:CPTXYGraph)
    {
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        //宣告最大和最小的local範圍
        let xMin = 0.0
        let xMax = Double(plotDatas.count) / 5
        let yMin = 0.0
        let yMax = yValueMax * 1.4
        //設定local範圍
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin))
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMin), lengthDecimal: CPTDecimalFromDouble(yMax - yMin))
        //允許使用者跟圖表互動
        plotSpace.allowsUserInteraction = true
        // 讓globalRang和localRange一致，達到只能橫向移動的結果
        plotSpace.globalYRange = plotSpace.yRange
        // 指定事件監聽器
        plotSpace.delegate = self
    }
    // 圖表標題
    func setGraphTitle(setGraph graph:CPTXYGraph, name:String)
    {
        //設定樣式
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.black()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 16.0
        titleStyle.textAlignment = .center
        // set to graph
        graph.titleTextStyle = titleStyle//設定文字樣式
        graph.title = name//設定標題
        graph.titlePlotAreaFrameAnchor = .top//文字在畫面的基準位置
        graph.titleDisplacement = CGPoint(x: 0.0, y: -16.0)//細部調整位置
    }
    //
    func createScatterPlot(lineColor color:CGColor, plotID name:String) -> CPTScatterPlot
    {
        // 線條樣式
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineJoin = .round
        lineStyle.lineCap = .round
        lineStyle.lineWidth = 2
        lineStyle.lineColor = CPTColor(cgColor: color)
        // 節點樣式
        let lineSymbol = CPTPlotSymbol()
        lineSymbol.symbolType = .ellipse
        lineSymbol.fill = CPTFill(color: CPTColor.white())
        lineSymbol.lineStyle = lineStyle
        lineSymbol.size = CGSize(width: 10.0, height: 10.0)
        // 產生plot
        let result = CPTScatterPlot()
        // 設定樣式
        result.dataLineStyle = lineStyle
        result.plotSymbol = lineSymbol
        // 其他設定
        result.curvedInterpolationOption = .catmullCustomAlpha
        result.interpolation = .linear
        result.identifier = name as NSCoding & NSCopying & NSObjectProtocol
        //回傳
        return result
    }
    

}
// MARK:- CPTP Delegate, DataSource
extension ViewController: CPTPlotDelegate, CPTPlotDataSource
{
    // 有多少個資料要顯示
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(plotDatas.count)
    }
    //回傳該點資料上的值
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any?
    {
        if fieldEnum == UInt(CPTScatterPlotField.Y.rawValue)
        {
            for i in 0..<myPlotObj.count
            {
                if plot == myPlotObj[i].plot
                {
                    
                    return plotDatas[Int(idx)].rates[myPlotObj[i].name]!
                }
            }
        }
        
        return idx
    }
    
}

//MARK:- CPTPlotSpaceDelegate
extension ViewController:CPTPlotSpaceDelegate
{
    func plotSpace(_ space: CPTPlotSpace, shouldHandlePointingDeviceDownEvent event: UIEvent, at point: CGPoint) -> Bool
    {
        guard let xySpace = space as? CPTXYPlotSpace,
              let iAxis = xySpace.graph?.axisSet?.axes?.last as? CPTXYAxis,
              let plotPoint = xySpace.plotPoint(for: event),
              let annotation = self.markerAnnotation,
              let textLayer = annotation.contentLayer as? CPTTextLayer else { return true }
        
        var xNumber:NSNumber = plotPoint[CPTCoordinate.X.rawValue]
        if xySpace.xRange.contains(xNumber)
        {
            // x軸是以data的index排序下來，所以要從doubleValue抓到附近的index
            var x:UInt = UInt(lround(xNumber.doubleValue))
            // 標註線得要在有資料的點上才能正確顯示，而圖表是有可能拉超過的
            if x >= plotDatas.count
            {
                x = UInt(plotDatas.count - 1)
            }
            xNumber = NSNumber(value: x)
            var showTextLayer = ""
            var count = 0
            for i in 0..<myPlotObj.count
            {
                let item = myPlotObj[i]
                if item.plotCtrl.isOn == false // 判斷數值是否要顯示
                {
                    continue
                }
                if count != 0// 判斷是否要斷行再輸出文字
                {
                    showTextLayer += "\n"
                }
                let xValue = plotDatas[Int(x)].rates[item.name]
                let plotValueFormat = String.init(format: "%1.3f", xValue?.doubleValue ?? 0)
                // add string
                showTextLayer += "\(item.name ?? ""):\(plotValueFormat)"
                // add count
                count += 1
            }
            textLayer.text = showTextLayer
            textLayer.isHidden = false
            // 調整註解顯示的位置
            let width = (textLayer.frame.width / 2) * 0.01// 取出文字框長度的一半，再乘上0.01做x軸位置的偏移
            let topPath = xySpace.yRange.maxLimit.doubleValue * 0.9
            let xPath = xNumber.doubleValue + Double(width)
            annotation.anchorPlotPoint = [NSNumber(value: xPath), NSNumber(value: topPath) ]
            //直線該顯示的位置
            iAxis.orthogonalPosition = xNumber
            iAxis.isHidden = false
        }
        else
        {
            iAxis.isHidden = true
        }
        
        return true
    }
    
    func plotSpace(_ space: CPTPlotSpace, shouldHandlePointingDeviceDraggedEvent event: UIEvent, at point: CGPoint) -> Bool
    {
        return plotSpace(space, shouldHandlePointingDeviceDownEvent: event, at: point)
    }
    
    func plotSpace(_ space: CPTPlotSpace, shouldHandlePointingDeviceUp event: UIEvent, at point: CGPoint) -> Bool {
        return true
    }
}
