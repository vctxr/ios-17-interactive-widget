//
//  FilterIntent.swift
//  DemoWidget
//
//  Created by victor.cuaca on 03/09/23.
//

import AppIntents

struct FilterIntent: AppIntent {
    static var title: LocalizedStringResource { "Filter Users" }
    static var description = IntentDescription("Filter users based on a range of ids.")
    
    @Parameter(title: "Filter Type")
    private var filterType: Int
    
    init(filterType: Int) {
        self.filterType = filterType
    }
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(filterType, forKey: "filterType")
        return .result()
    }
}
