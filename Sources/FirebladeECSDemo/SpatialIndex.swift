public protocol Locatable {
    associatedtype type where type: Locatable
    func distance(_ other: type) -> Double
}

public protocol SpatialIndex {
    associatedtype type where type: Locatable
    @discardableResult func add(_ locatable: type) -> Bool
    func allWithinBounds(_ others: [type]) -> [type]
    func allWithinDistance(_ other: type, _ distance: Double) -> [type]
}
