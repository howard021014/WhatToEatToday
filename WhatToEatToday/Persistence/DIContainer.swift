//
//  DepedencyContainer.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2024-10-31.
//

import Foundation

class DIContainer {
    let coreDataStack: CoreDataStack
    let coreDataService: CoreDataService
    
    init() {
        self.coreDataStack = CoreDataStack()
        self.coreDataService = CoreDataServiceImpl(context: coreDataStack.container.viewContext)
    }
}
