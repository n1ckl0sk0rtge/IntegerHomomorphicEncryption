//
//  Gaussian.swift
//  IntegerHomomorphicEncryption
//
//  Created by Nicklas Körtge on 03.04.21.
//
// inspired by C code form https://www.projectrhea.org/rhea/index.php/The_principles_for_how_to_generate_random_samples_from_a_Gaussian_distribution

import Foundation

protocol Distribution {
    func getSample() -> Double
}


class NormalDistribution : Distribution {

    var mean : Double = 0
    var deviation : Double = 0
    
    var t : Double = 0.0
    
    init(mean: Double, deviation: Double) {
        self.mean = mean
        self.deviation = deviation
    }
    
    // Marsaglia polar method
    func getSample() -> Double {
        var x, w1, w2, r : Double
         
        if( t == 0 ){
            repeat {
                w1 = 2.0 * Double.random(in: 0...1.0) - 1.0
                w2 = 2.0 * Double.random(in: 0...1.0) - 1.0
                r = w1 * w1 + w2 * w2
            } while (r >= 1.0)
            
            r = sqrt( -2.0 * log(r) / r )
            t = w2 * r
            return( mean + w1 * r * deviation )
        } else {
            x = t
            t = 0.0
            return( mean + x * deviation)
        }
    }
    
}
