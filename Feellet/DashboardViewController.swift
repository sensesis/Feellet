import UIKit
import SwiftUI
import Charts

class DashboardViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: Feellet.ExpenseViewModel
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let emotionFeedbackView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emotionCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emotionFeedbackLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    init(viewModel: Feellet.ExpenseViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateEmotionFeedback()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "지출 통계"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        setupCharts()
        setupEmotionFeedback()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupCharts() {
        // 카테고리별 지출 차트
        let pieChartViewController = UIHostingController(rootView: ExpensePieChartView(data: viewModel.categoryData))
        let pieChartView = pieChartViewController.view!
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        addChild(pieChartViewController)
        stackView.addArrangedSubview(pieChartView)
        pieChartViewController.didMove(toParent: self)
        
        // 일별 지출 추이 차트
        let lineChartViewController = UIHostingController(rootView: ExpenseLineChartView(data: viewModel.dailyData))
        let lineChartView = lineChartViewController.view!
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        addChild(lineChartViewController)
        stackView.addArrangedSubview(lineChartView)
        lineChartViewController.didMove(toParent: self)
        
        // 감정별 지출 차트
        let emotionChartViewController = UIHostingController(rootView: EmotionBarChartView(data: viewModel.emotionData))
        let emotionChartView = emotionChartViewController.view!
        emotionChartView.translatesAutoresizingMaskIntoConstraints = false
        addChild(emotionChartViewController)
        stackView.addArrangedSubview(emotionChartView)
        emotionChartViewController.didMove(toParent: self)
        
        // 차트 높이 설정
        [pieChartView, lineChartView, emotionChartView].forEach { chartView in
            chartView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        }
    }
    
    private func setupEmotionFeedback() {
        emotionFeedbackView.addSubview(emotionCountLabel)
        emotionFeedbackView.addSubview(emotionFeedbackLabel)
        stackView.addArrangedSubview(emotionFeedbackView)
        
        NSLayoutConstraint.activate([
            emotionCountLabel.topAnchor.constraint(equalTo: emotionFeedbackView.topAnchor, constant: 16),
            emotionCountLabel.leadingAnchor.constraint(equalTo: emotionFeedbackView.leadingAnchor, constant: 16),
            emotionCountLabel.trailingAnchor.constraint(equalTo: emotionFeedbackView.trailingAnchor, constant: -16),
            
            emotionFeedbackLabel.topAnchor.constraint(equalTo: emotionCountLabel.bottomAnchor, constant: 12),
            emotionFeedbackLabel.leadingAnchor.constraint(equalTo: emotionFeedbackView.leadingAnchor, constant: 16),
            emotionFeedbackLabel.trailingAnchor.constraint(equalTo: emotionFeedbackView.trailingAnchor, constant: -16),
            emotionFeedbackLabel.bottomAnchor.constraint(equalTo: emotionFeedbackView.bottomAnchor, constant: -16)
        ])
    }
    
    private func updateEmotionFeedback() {
        // 감정별 카운트 계산
        var emotionCounts: [Feellet.Emotion: Int] = [:]
        for transaction in viewModel.transactions {
            emotionCounts[transaction.emotion, default: 0] += 1
        }
        
        // 감정 카운트 텍스트 생성
        let countText = "행복😊: \(emotionCounts[.happy] ?? 0)회\n보통😐: \(emotionCounts[.neutral] ?? 0)회\n슬픔😢: \(emotionCounts[.sad] ?? 0)회"
        emotionCountLabel.text = countText
        
        // 가장 많은 감정 찾기
        let maxCount = emotionCounts.values.max() ?? 0
        let dominantEmotions = emotionCounts.filter { $0.value == maxCount }.map { $0.key }
        
        // 피드백 메시지 생성
        let feedback: String
        if dominantEmotions.count > 1 {
            feedback = "다양한 감정과 함께 소비하고 계시네요. 균형 잡힌 소비 생활을 하고 계십니다! 👏"
        } else if let dominantEmotion = dominantEmotions.first {
            switch dominantEmotion {
            case .happy:
                feedback = "긍정적인 소비 습관을 가지고 계시네요! 행복한 소비가 계속되길 바랍니다. ✨"
            case .neutral:
                feedback = "차분하고 신중한 소비를 하고 계시네요. 합리적인 소비 습관을 잘 유지하고 계십니다. 👍"
            case .sad:
                feedback = "최근 소비에 대해 걱정이 있으신가요? 잠시 소비 계획을 점검해보는 것은 어떨까요? 💭"
            }
        } else {
            feedback = "소비 내역을 기록하면 감정 분석 결과를 확인할 수 있습니다. 📝"
        }
        
        emotionFeedbackLabel.text = feedback
    }
}

// MARK: - Chart Views
private struct ExpensePieChartView: View {
    let data: [(String, Double)]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("카테고리별 지출")
                .font(.headline)
                .padding(.leading)
            
            if data.isEmpty {
                Text("아직 지출 내역이 없습니다.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                Chart {
                    ForEach(data, id: \.0) { category, amount in
                        SectorMark(
                            angle: .value("Amount", amount),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("Category", category))
                    }
                }
                .frame(height: 250)
                .padding()
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

private struct ExpenseLineChartView: View {
    let data: [(Date, Double)]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("일별 지출 추이")
                .font(.headline)
                .padding(.leading)
            
            if data.isEmpty {
                Text("아직 지출 내역이 없습니다.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                Chart {
                    ForEach(data, id: \.0) { date, amount in
                        LineMark(
                            x: .value("Date", date),
                            y: .value("Amount", amount)
                        )
                        .symbol(Circle())
                    }
                }
                .frame(height: 250)
                .padding()
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

private struct EmotionBarChartView: View {
    let data: [(String, Double)]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("감정별 지출")
                .font(.headline)
                .padding(.leading)
            
            if data.isEmpty {
                Text("아직 지출 내역이 없습니다.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                Chart {
                    ForEach(data, id: \.0) { emotion, amount in
                        BarMark(
                            x: .value("Emotion", emotion),
                            y: .value("Amount", amount)
                        )
                    }
                }
                .frame(height: 250)
                .padding()
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
} 