//
//  MathModulo.swift
//  IntegerHomomorphicEncryption
//
//  Created by Nicklas Körtge on 09.04.21.
//

import Foundation

infix operator %% : MultiplicationPrecedence
func %%<T: BinaryInteger>(lhs: T, rhs: T) -> T {
    let rem = lhs % rhs // -rhs <= rem <= rhs
    return rem >= 0 ? rem : rem + rhs
}

func log_b(_ value: Double, _ base: Double) -> Double {
    return log(value)/log(base)
}
