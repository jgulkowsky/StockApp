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
import StockAppLogic

class QuoteViewController: BaseViewController {
    private var viewModel: QuoteViewModel
    
    private lazy var loadingView = UIActivityIndicatorView(style: .large)
    
    private lazy var errorLabel = ErrorLabel()
    
    private lazy var errorRefreshButton: ErrorRefreshButton = {
        let button = ErrorRefreshButton()
        button.addTarget(self, action: #selector(errorRefreshButtonTapped), for: .touchUpInside)
        return button
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
    
    private static let labelsPaddingTop: Double = 20
    private static let labelsPaddingBottom: Double = 15
    
    init(viewModel: QuoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        setupConstraints()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.onViewWillDisappear()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupConstraints()
    }
    
    override func setupConstraints() {
        loadingView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
        
        errorLabel.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                .inset(ErrorLabel.paddingTop)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
                .inset(UIView.horizontalPadding)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
                .inset(UIView.horizontalPadding)
        }
        
        errorRefreshButton.snp.remakeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom)
                .offset(ErrorRefreshButton.paddingTop)
            make.centerX.equalToSuperview()
            make.width.equalTo(ErrorRefreshButton.width)
            make.height.equalTo(ErrorRefreshButton.height)
        }
        
        chartView.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
                .inset(UIView.horizontalPadding)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
                .inset(UIView.horizontalPadding)
        }
        
        setupLabelsConstraints()
    }
}

extension QuoteViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {}
}

private extension QuoteViewController {
    func addViews() {
        view.addSubview(loadingView)
        view.addSubview(errorLabel)
        view.addSubview(errorRefreshButton)
        view.addSubview(chartView)
        view.addSubview(bidPriceLabel)
        view.addSubview(askPriceLabel)
        view.addSubview(lastPriceLabel)
    }
    
    func setupLabelsConstraints() {
        if traitCollection.horizontalSizeClass == .compact {
            setupLabelsConstraintsVertically()
        } else {
            setupLabelsConstraintsHorizontally()
        }
    }
    
    func setupLabelsConstraintsVertically() {
        bidPriceLabel.snp.remakeConstraints { make in
            make.top.equalTo(chartView.snp.bottom)
                .offset(Self.labelsPaddingTop)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
                .inset(UIView.horizontalPadding)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
                .inset(UIView.horizontalPadding)
        }
        
        let offsetBetweenLabels: Double = 5
        
        askPriceLabel.snp.remakeConstraints { make in
            make.top.equalTo(bidPriceLabel.snp.bottom)
                .offset(offsetBetweenLabels)
            make.leading.equalTo(bidPriceLabel.snp.leading)
            make.trailing.equalTo(bidPriceLabel.snp.trailing)
        }
        
        lastPriceLabel.snp.remakeConstraints { make in
            make.top.equalTo(askPriceLabel.snp.bottom)
                .offset(offsetBetweenLabels)
            make.leading.equalTo(bidPriceLabel.snp.leading)
            make.trailing.equalTo(bidPriceLabel.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .inset(Self.labelsPaddingBottom)
        }
    }
    
    func setupLabelsConstraintsHorizontally() {
        let labelWidth = (UIScreen.main.bounds.width - 2 * UIView.horizontalPadding) / 3
        
        bidPriceLabel.snp.remakeConstraints { make in
            make.top.equalTo(chartView.snp.bottom)
                .offset(Self.labelsPaddingTop)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
                .inset(UIView.horizontalPadding)
            make.width.equalTo(labelWidth)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .inset(Self.labelsPaddingBottom)
        }
        
        askPriceLabel.snp.remakeConstraints { make in
            make.top.equalTo(chartView.snp.bottom)
                .offset(Self.labelsPaddingTop)
            make.leading.equalTo(bidPriceLabel.snp.trailing)
            make.width.equalTo(labelWidth)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .inset(Self.labelsPaddingBottom)
        }
        
        lastPriceLabel.snp.remakeConstraints { make in
            make.top.equalTo(chartView.snp.bottom)
                .offset(Self.labelsPaddingTop)
            make.leading.equalTo(askPriceLabel.snp.trailing)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
                .inset(UIView.horizontalPadding)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .inset(Self.labelsPaddingBottom)
        }
    }
    
    func setupBindings() {
        viewModel.titlePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] title in
                self?.title = title
            }
            .store(in: &store)
        
        viewModel.statePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.loadingView.isHidden = state != .loading
                self?.errorLabel.isHidden = state != .error
                self?.errorRefreshButton.isHidden = state != .error
                self?.chartView.isHidden = state != .dataObtained
                self?.bidPriceLabel.isHidden = state != .dataObtained
                self?.askPriceLabel.isHidden = state != .dataObtained
                self?.lastPriceLabel.isHidden = state != .dataObtained
                
                if state == .loading {
                    self?.loadingView.startAnimating()
                } else {
                    self?.loadingView.stopAnimating()
                }
            }
            .store(in: &store)
        
        viewModel.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.errorLabel.text = error
            }
            .store(in: &store)

        viewModel.chartDataPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] chartData in
                self?.setChartView(basedOn: chartData)
            }
            .store(in: &store)
        
        viewModel.bidPricePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] bidPrice in
                self?.bidPriceLabel.text = bidPrice
            }
            .store(in: &store)
        
        viewModel.askPricePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] askPrice in
                self?.askPriceLabel.text = askPrice
            }
            .store(in: &store)
        
        viewModel.lastPricePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] lastPrice in
                self?.lastPriceLabel.text = lastPrice
            }
            .store(in: &store)
    }
    
    func setChartView(basedOn chartData: StockAppLogic.ChartData) {
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
        set.highlightEnabled = false
        let data = CandleChartData(dataSet: set)
        chartView.data = data
    }
    
    // this method is thighlty combined with func getDate(outFrom daysToDate: Double) -> Date - don't change one without the second one
    func getDaysFromNow(to date: Date) -> Double {
        let daysToDate = Date().distance(to: date) / (3600 * 24)
        return daysToDate
        // we need to use daysToDate mapping because when passing $0.date.timeIntervalSince1970 it is too big and the candle sticks are too small - it's a known bug in DGCharts
    }
    
    @objc func errorRefreshButtonTapped() {
        viewModel.onErrorRefreshButtonTapped()
    }
}
