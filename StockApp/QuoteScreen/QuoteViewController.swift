//
//  QuoteViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 18/12/2023.
//

import UIKit
import SnapKit
import Combine
import DGCharts

class QuoteViewController: UIViewController {
    private var viewModel: QuoteViewModel
    
    private lazy var loadingView = UIActivityIndicatorView(style: .large)
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var chartView: CandleStickChartView = {
        class XAxisValueFormatter: AxisValueFormatter {
            lazy private var dateFormatter: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                dateFormatter.dateFormat = "dd/MM"
                return dateFormatter
            }()
            
            func stringForValue(_ value: Double, axis: AxisBase?) -> String {
                let daysToDate = value
                let date = getDate(outFrom: daysToDate)
                return dateFormatter.string(from: date)
            }
            
            // this method is thightly combined with func getDaysFromNow(to date: Date) -> Double - don't change one without the second one
            private func getDate(outFrom daysToDate: Double) -> Date {
                let secondsToDate = 3600 * 24 * daysToDate
                let date = Date().addingTimeInterval(secondsToDate)
                return date
                // as we mapped $0.date.timeIntervalSince1970 into daysToDate - now it is time to revert this process and then get Date out of timeIntervalSince1970
            }
        }
        
        let chartView = CandleStickChartView()
        chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartView.xAxis.avoidFirstLastClippingEnabled = true
        chartView.xAxis.valueFormatter = XAxisValueFormatter()
        chartView.legend.enabled = false
        chartView.setScaleEnabled(false)
        return chartView
    }()
    
    private lazy var bidPriceLabel = UILabel(frame: .zero)
    private lazy var askPriceLabel = UILabel(frame: .zero)
    private lazy var lastPriceLabel = UILabel(frame: .zero)
    
    private var store = Set<AnyCancellable>()
    
    init(viewModel: QuoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addViews()
        setupConstraints()
        setupBindings()
    }
}

extension QuoteViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("@jgu: chartValueSelected: \(entry)")
    }
}

private extension QuoteViewController {
    func addViews() {
        view.addSubview(loadingView)
        view.addSubview(errorLabel)
        view.addSubview(chartView)
        view.addSubview(bidPriceLabel)
        view.addSubview(askPriceLabel)
        view.addSubview(lastPriceLabel)
    }
    
    func setupConstraints() {
        loadingView.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview()
            make.height.width.equalTo(30)
        }
        
        errorLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(20.0)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20.0)
        }
        
        chartView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(20.0)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20.0)
            make.height.equalTo(self.view.frame.size.height / 2)
        }
        
        bidPriceLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(chartView.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(20.0)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20.0)
        }
        
        askPriceLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(bidPriceLabel.snp.bottom)
            make.leading.equalTo(bidPriceLabel.snp.leading)
            make.trailing.equalTo(bidPriceLabel.snp.trailing)
        }
        
        lastPriceLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(askPriceLabel.snp.bottom)
            make.leading.equalTo(bidPriceLabel.snp.leading)
            make.trailing.equalTo(bidPriceLabel.snp.trailing)
        }
    }
    
    func setupBindings() {
        viewModel.statePublisher
            .receive(on: RunLoop.main)
            .sink { state in
                self.loadingView.isHidden = state != .loading
                self.errorLabel.isHidden = state != .error
                self.chartView.isHidden = state != .dataObtained
                self.bidPriceLabel.isHidden = state != .dataObtained
                self.askPriceLabel.isHidden = state != .dataObtained
                self.lastPriceLabel.isHidden = state != .dataObtained
                
                if state == .loading {
                    self.loadingView.startAnimating()
                } else {
                    self.loadingView.stopAnimating()
                }
            }
            .store(in: &store)
        
        viewModel.errorPublisher
            .receive(on: RunLoop.main)
            .sink { self.errorLabel.text = $0 }
            .store(in: &store)

        viewModel.chartDataPublisher
            .receive(on: RunLoop.main)
            .sink { self.setChartView(basedOn: $0) }
            .store(in: &store)
        
        viewModel.bidPricePublisher
            .receive(on: RunLoop.main)
            .sink { self.bidPriceLabel.text = $0 }
            .store(in: &store)
        
        viewModel.askPricePublisher
            .receive(on: RunLoop.main)
            .sink { self.askPriceLabel.text = $0 }
            .store(in: &store)
        
        viewModel.lastPricePublisher
            .receive(on: RunLoop.main)
            .sink { self.lastPriceLabel.text = $0 }
            .store(in: &store)
    }
    
    func setChartView(basedOn chartData: ChartData) {
        let entries = chartData.values.map {
            return CandleChartDataEntry(
                x: getDaysFromNow(to: $0.date),
                shadowH: $0.high,
                shadowL: $0.low,
                open: $0.open,
                close: $0.close)
        }
        let set = CandleChartDataSet(entries: entries, label: "")
        set.barSpace = 0.1
        set.drawValuesEnabled = false
        let data = CandleChartData(dataSet: set)
        chartView.data = data
    }
    
    // this method is thighlty combined with func getDate(outFrom daysToDate: Double) -> Date - don't change one without the second one
    func getDaysFromNow(to date: Date) -> Double {
        let daysToDate = Date().distance(to: date) / (3600 * 24)
        return daysToDate
        // we need to use daysToDate mapping because when passing $0.date.timeIntervalSince1970 it is too big and the candle sticks are too small - it's a known bug in DGCharts
    }
}
