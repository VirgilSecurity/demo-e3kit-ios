//
//  TimeInMs.swift
//  E3Kit iOS Swift Sample
//
//  Created by Matheus Cardoso on 9/5/19.
//  Copyright © 2019 cardoso. All rights reserved.
//

import Foundation

func timeInMs() -> Double {
    return Double(DispatchTime.now().rawValue)/1000000
}
