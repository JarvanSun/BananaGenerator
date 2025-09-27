import Foundation

// MARK: - Safe Subscript
extension Array {
    /// Safely accesses an element at the given index
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

// MARK: - URL Array Extensions
extension Array where Element == URL {
    /// Returns the count if non-empty, otherwise nil
    var nonEmptyCount: Int? {
        isEmpty ? nil : count
    }
}