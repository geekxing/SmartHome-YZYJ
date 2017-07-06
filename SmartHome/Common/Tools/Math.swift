//
//  Math.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/23.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import Foundation

func averageOf(numbers:[Double]) -> Double {
    var sum = 0.0
    for n in numbers {
        sum += n
    }
    if numbers.count != 0 {
        return sum / Double(numbers.count)
    } else {
        return 0
    }
}

func maxOf(numbers:[Double]) -> Double {
    if numbers.count == 0 {
        return 0
    }
    var max = numbers[0]
    for n in numbers {
        if n > max {
            max = n
        }
    }
    return max
}

func minOf(numbers:[Double]) -> Double {
    if numbers.count == 0 {
        return 0
    }
    var min = numbers[0]
    for n in numbers {
        if n < min {
            min = n
        }
    }
    return min
}
