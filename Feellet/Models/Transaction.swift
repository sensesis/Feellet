import Foundation

// MARK: - Models
enum Category: String, CaseIterable {
    case food = "식비"
    case transportation = "교통비"
    case shopping = "쇼핑"
    case entertainment = "여가"
    case health = "의료/건강"
    case education = "교육"
    case others = "기타"
}

enum Emotion: String, CaseIterable {
    case happy = "😊"
    case neutral = "😐"
    case sad = "😢"
}

struct Transaction: Identifiable {
    let id: UUID
    let amount: Double
    let category: Category
    let date: Date
    let emotion: Emotion
    let memo: String
    
    init(id: UUID = UUID(), amount: Double, category: Category, date: Date = Date(), emotion: Emotion, memo: String = "") {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.emotion = emotion
        self.memo = memo
    }
}

// MARK: - View Models
class ExpenseViewModel {
    private(set) var transactions: [Transaction] = []
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
    }
    
    var categoryData: [(String, Double)] {
        Dictionary(grouping: transactions, by: { $0.category })
            .map { (category, transactions) in
                (category.rawValue, transactions.reduce(0) { $0 + $1.amount })
            }
            .sorted { $0.1 > $1.1 }
    }
    
    var dailyData: [(Date, Double)] {
        Dictionary(grouping: transactions, by: { Calendar.current.startOfDay(for: $0.date) })
            .map { (date, transactions) in
                (date, transactions.reduce(0) { $0 + $1.amount })
            }
            .sorted { $0.0 < $1.0 }
    }
    
    var emotionData: [(String, Double)] {
        Dictionary(grouping: transactions, by: { $0.emotion })
            .map { (emotion, transactions) in
                (emotion.rawValue, transactions.reduce(0) { $0 + $1.amount })
            }
            .sorted { $0.1 > $1.1 }
    }
}
