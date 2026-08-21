public import Dimension_Primitives

extension Tagged where Tag == Coordinate.X<Time.Julian.Space>, Underlying == Double {

    public static let unixEpoch: Self = Self(2_440_587.5)

    public static let j2000: Self = Self(2_451_545.0)

    public static let zero: Self = Self(0.0)
}
