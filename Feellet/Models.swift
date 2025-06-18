import Foundation

public enum Feellet {
    public enum Category: String, CaseIterable {
        case food = "식비"
        case transportation = "교통비"
        case shopping = "쇼핑"
        case entertainment = "여가"
        case health = "의료/건강"
        case education = "교육"
        case others = "기타"
    }

    public enum Emotion: String, CaseIterable {
        case happy = "😊"
        case neutral = "😐"
        case sad = "😢"
    }

    public struct Transaction: Identifiable {
        public let id: UUID
        public let amount: Double
        public let category: Category
        public let date: Date
        public let emotion: Emotion
        public let memo: String
        
        public init(id: UUID = UUID(), amount: Double, category: Category, date: Date = Date(), emotion: Emotion, memo: String = "") {
            self.id = id
            self.amount = amount
            self.category = category
            self.date = date
            self.emotion = emotion
            self.memo = memo
        }
    }

    public class ExpenseViewModel {
        private(set) public var transactions: [Transaction] = []
        private(set) public var budgetAmount: Double = 0
        
        public init() {}
        
        public func setBudget(_ amount: Double) {
            budgetAmount = amount
        }
        
        public func addTransaction(_ transaction: Transaction) {
            transactions.append(transaction)
        }
        
        public var totalSpent: Double {
            transactions.reduce(0) { $0 + $1.amount }
        }
        
        public var remainingBudget: Double {
            budgetAmount - totalSpent
        }
        
        public var categoryData: [(String, Double)] {
            Dictionary(grouping: transactions, by: { $0.category })
                .map { (category, transactions) in
                    (category.rawValue, transactions.reduce(0) { $0 + $1.amount })
                }
                .sorted { $0.1 > $1.1 }
        }
        
        public var dailyData: [(Date, Double)] {
            Dictionary(grouping: transactions, by: { Calendar.current.startOfDay(for: $0.date) })
                .map { (date, transactions) in
                    (date, transactions.reduce(0) { $0 + $1.amount })
                }
                .sorted { $0.0 < $1.0 }
        }
        
        public var emotionData: [(String, Double)] {
            Dictionary(grouping: transactions, by: { $0.emotion })
                .map { (emotion, transactions) in
                    (emotion.rawValue, transactions.reduce(0) { $0 + $1.amount })
                }
                .sorted { $0.1 > $1.1 }
        }
    }
} 