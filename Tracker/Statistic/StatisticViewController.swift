import UIKit

final class StatisticViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let stackView = UIStackView()
    private let cardsContainer = UIView()
    private var cardViews: [UIView] = []
    private let emptyImageView = UIImageView()
    private let emptyLabel = UILabel()
    private var cardCounterLabel: [UILabel] = []
    private var statsCounterLabels: [UILabel] = []
    private var cardInnerViews: [UIView] = []
    
    // MARK: - Private Properties
    
    private let trackerRecordStore = TrackerRecordStore()
    private let colors = Colors()
    
    // MARK: -  Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStackView()
        setupTitle()
        setupEmptyImageView()
        setupEmptyLabel()
        setupCardsContainer()
        setupCardsContent()
        setupConstraints()
        reloadStatistics()
    }
    
    // MARK: - Setup UI Elements
    
    private func setupView() {
        view.backgroundColor = colors.viewBackgroundColor
        view.contentMode = .scaleToFill
    }
    
    private func setupCardsContainer() {
        cardsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardsContainer)
        cardsContainer.addSubview(stackView)
    }
    private func setupStackView() {
        view.backgroundColor = colors.viewBackgroundColor
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupCardsContent() {
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        cardInnerViews.removeAll()
        cardCounterLabel.removeAll()
        let titles = [
            NSLocalizedString("best_period", comment: ""),
            NSLocalizedString("perfect_days", comment: ""),
            NSLocalizedString("completed_trackers", comment: ""),
            NSLocalizedString("average_value", comment: "")
        ]
        let cgColors: [CGColor] = [
            UIColor(named: "colorSelection1")?.cgColor,
            UIColor(named: "colorSelection9")?.cgColor,
            UIColor(named: "colorSelection3")?.cgColor
        ].compactMap { $0 }
        for i in 0..<4 {
            let card = GradientCardView(borderWidth: 1.0, cornerRadius: 16.0, colors: cgColors)
            card.translatesAutoresizingMaskIntoConstraints = false
            let contentStack = UIStackView()
            contentStack.axis = .vertical
            contentStack.alignment = .leading
            contentStack.spacing = 7
            contentStack.translatesAutoresizingMaskIntoConstraints = false
            let counter = UILabel()
            counter.text = "0"
            counter.font = UIFont.systemFont(ofSize: 34, weight: .bold)
            counter.textColor = colors.trackerTintColor()
            let description = UILabel()
            description.text = titles[i]
            description.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            description.textColor = colors.trackerTintColor()
            contentStack.addArrangedSubview(counter)
            contentStack.addArrangedSubview(description)
            card.contentView.addSubview(contentStack)
            NSLayoutConstraint.activate([
                contentStack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: 12),
                contentStack.trailingAnchor.constraint(lessThanOrEqualTo: card.contentView.trailingAnchor, constant: -12),
                contentStack.centerYAnchor.constraint(equalTo: card.contentView.centerYAnchor),
                card.heightAnchor.constraint(equalToConstant: 90)
            ])
            stackView.addArrangedSubview(card)
            cardViews.append(card)
            cardCounterLabel.append(counter)
            statsCounterLabels.append(counter)
        }
    }
    
    private func setupTitle(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NSLocalizedString("statistics_title", comment: "Title for the Statistics view")
    }
    
    private func setupEmptyImageView() {
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.image = UIImage(named: "zero_statistic")
        emptyImageView.contentMode = .scaleAspectFit
        emptyImageView.isHidden = true
        view.addSubview(emptyImageView)
    }
    
    private func setupEmptyLabel() {
        emptyLabel.textColor = colors.trackerTintColor()
        emptyLabel.text = NSLocalizedString("no_statistics", comment: "Text indicating empty statistics")
        emptyLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyLabel.contentMode = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardsContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cardsContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            cardsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -210),
            stackView.topAnchor.constraint(equalTo: cardsContainer.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: cardsContainer.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: cardsContainer.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: cardsContainer.bottomAnchor),
        ])
    }
    
    // MARK: - Private Methods
    
    private func showEmptyState(_ show: Bool) {
        emptyImageView.isHidden = !show
        emptyLabel.isHidden = !show
        cardsContainer.isHidden = show
    }
    
    private func reloadStatistics() {
        DispatchQueue.global(qos: .userInitiated).async {
            var bestPeriod = 0
            var perfectDays = 0
            var totalCompleted = 0
            var averageValue = 0
            do {
                bestPeriod = try self.trackerRecordStore.fetchBestPeriod()
                perfectDays = try self.trackerRecordStore.fetchPerfectDaysCount()
                totalCompleted = try self.trackerRecordStore.fetchCompletedTrackers()
                averageValue = try self.trackerRecordStore.fetchAverageValue()
            } catch {
                print("Failed to compute stats: \(error)")
            }
            let isEmptyState = (bestPeriod == 0 && perfectDays == 0 && totalCompleted == 0 && averageValue == 0)
            DispatchQueue.main.async {
                if isEmptyState {
                    self.showEmptyState(true)
                } else {
                    self.showEmptyState(false)
                    if self.statsCounterLabels.count >= 4 {
                        self.statsCounterLabels[0].text = "\(bestPeriod)"
                        self.statsCounterLabels[1].text = "\(perfectDays)"
                        self.statsCounterLabels[2].text = "\(totalCompleted)"
                        self.statsCounterLabels[3].text = "\(averageValue)"
                    } else {
                        print("statsCounterLabels count mismatch: \(self.statsCounterLabels.count)")
                    }
                }
            }
        }
    }
}

extension StatisticViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidUpdateRecords(_ store: TrackerRecordStore) {
        reloadStatistics()
    }
}
