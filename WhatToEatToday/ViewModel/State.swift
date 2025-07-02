//
//  State.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2025-05-30.
//

import Foundation

enum State<Value> {
    case idle
    case loading
    case success(Value)
    case failure(Error)
}
