public import Dimension_Primitives

extension Tagged where Tag == Coordinate.X<Time.Julian.Space>, Underlying == Double {

    public var modified: Double {
        underlying - Time.Julian.Offset.modified.underlying
    }
}
