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
    
    private lazy var chartView: CandleStickChartView = {
        let chartView = CandleStickChartView()
        chartView.backgroundColor = .purple
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
        view.addSubview(chartView)
        view.addSubview(bidPriceLabel)
        view.addSubview(askPriceLabel)
        view.addSubview(lastPriceLabel)
    }
    
    func setupConstraints() {
        chartView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(20.0)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20.0)
            make.height.equalTo(100.0)
        }
        
        bidPriceLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(chartView.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(20.0)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20.0)
            make.height.equalTo(30.0)
        }
        
        askPriceLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(bidPriceLabel.snp.bottom)
            make.leading.equalTo(bidPriceLabel.snp.leading)
            make.trailing.equalTo(bidPriceLabel.snp.trailing)
            make.height.equalTo(bidPriceLabel.snp.height)
        }
        
        lastPriceLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(askPriceLabel.snp.bottom)
            make.leading.equalTo(bidPriceLabel.snp.leading)
            make.trailing.equalTo(bidPriceLabel.snp.trailing)
            make.height.equalTo(bidPriceLabel.snp.height)
        }
    }
    
    func setupBindings() {
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
            CandleChartDataEntry(
                x: $0.date.timeIntervalSince1970,
                shadowH: $0.high,
                shadowL: $0.low,
                open: $0.open,
                close: $0.close)
        }
        let set = CandleChartDataSet(entries: entries, label: "Chart chart chart")
        let data = CandleChartData(dataSet: set)
        chartView.data = data
    }
}
