import UIKit
import FirebaseAuth

class MainViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = Feellet.ExpenseViewModel()
    
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
    
    private let budgetContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let budgetLabel: UILabel = {
        let label = UILabel()
        label.text = "목표 금액: 0원"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let spentLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 지출: 0원"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let remainingLabel: UILabel = {
        let label = UILabel()
        label.text = "남은 금액: 0원"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let setBudgetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("목표 금액 설정", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "금액을 입력하세요"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let categorySegmentedControl: UISegmentedControl = {
        let items = Feellet.Category.allCases.map { $0.rawValue }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "날짜"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let emotionLabel: UILabel = {
        let label = UILabel()
        label.text = "소비 감정"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emotionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let memoTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "메모"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var selectedEmotion: Feellet.Emotion?
    
    private let transactionListLabel: UILabel = {
        let label = UILabel()
        label.text = "지출 내역"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let transactionTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTableView()
    }
    
    // MARK: - UI Setup
    private func setupNavigationBar() {
        title = "지출 입력"
        
        // 대시보드 버튼 (오른쪽)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "대시보드",
            style: .plain,
            target: self,
            action: #selector(showDashboard)
        )
        
        // 로그아웃 버튼 (왼쪽)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "로그아웃",
            style: .plain,
            target: self,
            action: #selector(logoutButtonTapped)
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        // Setup budget view
        setupBudgetView()
        
        stackView.addArrangedSubview(amountTextField)
        stackView.addArrangedSubview(categorySegmentedControl)
        
        let dateStack = UIStackView(arrangedSubviews: [dateLabel, datePicker])
        dateStack.axis = .horizontal
        dateStack.spacing = 10
        stackView.addArrangedSubview(dateStack)
        
        stackView.addArrangedSubview(emotionLabel)
        stackView.addArrangedSubview(emotionStackView)
        
        setupEmotionButtons()
        
        stackView.addArrangedSubview(memoTextField)
        stackView.addArrangedSubview(saveButton)
        
        // Add transaction list
        stackView.addArrangedSubview(transactionListLabel)
        stackView.addArrangedSubview(transactionTableView)
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        setBudgetButton.addTarget(self, action: #selector(setBudgetTapped), for: .touchUpInside)
        
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
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            transactionTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])
        
        // 스크롤뷰가 컨텐츠에 맞게 스크롤되도록 설정
        scrollView.alwaysBounceVertical = true
    }
    
    private func setupBudgetView() {
        let budgetStack = UIStackView()
        budgetStack.axis = .vertical
        budgetStack.spacing = 8
        budgetStack.translatesAutoresizingMaskIntoConstraints = false
        
        budgetContainerView.addSubview(budgetStack)
        stackView.addArrangedSubview(budgetContainerView)
        
        [budgetLabel, spentLabel, remainingLabel, progressView, setBudgetButton].forEach {
            budgetStack.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            budgetStack.topAnchor.constraint(equalTo: budgetContainerView.topAnchor, constant: 16),
            budgetStack.leadingAnchor.constraint(equalTo: budgetContainerView.leadingAnchor, constant: 16),
            budgetStack.trailingAnchor.constraint(equalTo: budgetContainerView.trailingAnchor, constant: -16),
            budgetStack.bottomAnchor.constraint(equalTo: budgetContainerView.bottomAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    private func setupTableView() {
        transactionTableView.dataSource = self
        transactionTableView.delegate = self
    }
    
    private func updateBudgetLabels() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let spentRatio = viewModel.budgetAmount > 0 ? viewModel.totalSpent / viewModel.budgetAmount : 0
        let remainingRatio = 1.0 - spentRatio
        
        // 색상 설정 (남은 금액 기준)
        let statusColor: UIColor
        
        switch remainingRatio {
        case ..<(1.0/3.0):  // 33% 미만 남음 (위험)
            statusColor = .systemRed
        case (1.0/3.0)..<(2.0/3.0):  // 33% ~ 66% 남음 (주의)
            statusColor = .systemOrange
        default:  // 66% 이상 남음 (안전)
            statusColor = .systemGreen
        }
        
        let budgetText = "목표 금액: \(numberFormatter.string(from: NSNumber(value: viewModel.budgetAmount)) ?? "0")원"
        let spentText = "현재 지출: \(numberFormatter.string(from: NSNumber(value: viewModel.totalSpent)) ?? "0")원"
        let remainingText = "남은 금액: \(numberFormatter.string(from: NSNumber(value: viewModel.remainingBudget)) ?? "0")원"
        
        // 텍스트와 색상 설정
        let budgetAttributedText = NSMutableAttributedString(string: budgetText)
        budgetAttributedText.addAttribute(.foregroundColor, value: statusColor, range: (budgetText as NSString).range(of: "\(numberFormatter.string(from: NSNumber(value: viewModel.budgetAmount)) ?? "0")원"))
        budgetLabel.attributedText = budgetAttributedText
        
        let spentAttributedText = NSMutableAttributedString(string: spentText)
        spentAttributedText.addAttribute(.foregroundColor, value: statusColor, range: (spentText as NSString).range(of: "\(numberFormatter.string(from: NSNumber(value: viewModel.totalSpent)) ?? "0")원"))
        spentLabel.attributedText = spentAttributedText
        
        let remainingAttributedText = NSMutableAttributedString(string: remainingText)
        remainingAttributedText.addAttribute(.foregroundColor, value: statusColor, range: (remainingText as NSString).range(of: "\(numberFormatter.string(from: NSNumber(value: viewModel.remainingBudget)) ?? "0")원"))
        remainingLabel.attributedText = remainingAttributedText
        
        // 프로그레스 바 업데이트
        updateProgressBar(ratio: spentRatio, remainingRatio: remainingRatio)
    }
    
    // 프로그레스 바 추가
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .systemGray5
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private func setupEmotionButtons() {
        for emotion in Feellet.Emotion.allCases {
            let button = UIButton()
            button.setTitle(emotion.rawValue, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 40)
            button.addTarget(self, action: #selector(emotionButtonTapped(_:)), for: .touchUpInside)
            emotionStackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Actions
    @objc private func emotionButtonTapped(_ sender: UIButton) {
        guard let emotionTitle = sender.title(for: .normal),
              let emotion = Feellet.Emotion.allCases.first(where: { $0.rawValue == emotionTitle }) else { return }
        
        selectedEmotion = emotion
        
        // Reset all buttons
        emotionStackView.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
                button.backgroundColor = .clear
            }
        }
        
        // Highlight selected button
        sender.backgroundColor = .systemGray5
    }
    
    @objc private func setBudgetTapped() {
        let alert = UIAlertController(
            title: "목표 금액 설정",
            message: "이번 달 목표 지출 금액을 입력해주세요",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "금액"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "설정", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text,
                  let amount = Double(text) else { return }
            
            self?.viewModel.setBudget(amount)
            self?.updateBudgetLabels()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText),
              let emotion = selectedEmotion else {
            // Show error alert
            let alert = UIAlertController(
                title: "입력 오류",
                message: "금액과 감정을 모두 입력해주세요",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let category = Feellet.Category.allCases[categorySegmentedControl.selectedSegmentIndex]
        
        let transaction = Feellet.Transaction(
            amount: amount,
            category: category,
            date: datePicker.date,
            emotion: emotion,
            memo: memoTextField.text ?? ""
        )
        
        viewModel.addTransaction(transaction)
        updateBudgetLabels()
        transactionTableView.reloadData()
        
        // Reset form
        amountTextField.text = ""
        categorySegmentedControl.selectedSegmentIndex = 0
        datePicker.date = Date()
        memoTextField.text = ""
        selectedEmotion = nil
        emotionStackView.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
                button.backgroundColor = .clear
            }
        }
        
        // Show success message
        let alert = UIAlertController(
            title: "저장 완료",
            message: "지출이 저장되었습니다",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func showDashboard() {
        let dashboardVC = DashboardViewController(viewModel: viewModel)
        navigationController?.pushViewController(dashboardVC, animated: true)
    }
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(
            title: "로그아웃",
            message: "정말 로그아웃 하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            do {
                try Auth.auth().signOut()
                // 로그아웃 성공 시 로그인 화면으로 이동
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .fullScreen
                self?.view.window?.rootViewController = loginVC
            } catch {
                self?.showAlert(message: "로그아웃 중 오류가 발생했습니다.")
            }
        })
        
        present(alert, animated: true)
    }
    
    private func updateProgressBar(ratio: Double, remainingRatio: Double) {
        let progress = Float(min(max(ratio, 0), 1))
        progressView.progress = progress
        
        // 프로그레스 바 색상 업데이트 (남은 금액 기준)
        if remainingRatio < 1.0/3.0 {
            progressView.progressTintColor = .systemRed
        } else if remainingRatio < 2.0/3.0 {
            progressView.progressTintColor = .systemOrange
        } else {
            progressView.progressTintColor = .systemGreen
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        let transaction = viewModel.transactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - TransactionCell
class TransactionCell: UITableViewCell {
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emotionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [amountLabel, categoryLabel, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        contentView.addSubview(emotionLabel)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            emotionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emotionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with transaction: Feellet.Transaction) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        amountLabel.text = "\(numberFormatter.string(from: NSNumber(value: transaction.amount)) ?? "0")원"
        
        categoryLabel.text = transaction.category.rawValue
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: transaction.date)
        
        emotionLabel.text = transaction.emotion.rawValue
    }
}
