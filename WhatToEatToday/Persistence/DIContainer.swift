//
//  DepedencyContainer.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2024-10-31.
//

import Foundation

class DIContainer {
    static let shared = DIContainer()
    let coreDataService: CoreDataService
    
    private init() {
        self.coreDataService = CoreDataServiceImpl(context: CoreDataStack().container.viewContext)
    }
}
