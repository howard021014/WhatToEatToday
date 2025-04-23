//
//  DepedencyContainer.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2024-10-31.
//

import Foundation

class DIContainer {
    let coreDataStack = CoreDataStack.shared
    let coreDataService: CoreDataService
    
    init() {
        coreDataService = CoreDataServiceImpl(
            container: coreDataStack.container
        )
    }
}
