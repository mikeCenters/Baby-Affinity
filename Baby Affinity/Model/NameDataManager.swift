//
//  PersistenceManaegment.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/13/24.
//

import Foundation
import SwiftData

protocol NameDataManager {
    func fetchNames() async throws -> [Name]
    func addName(_ name: Name) async throws
    func deleteNames(_ names: [Name]) async throws
    func updateName(_ name: Name) async throws
    func getRank(of name: Name, from context: ModelContext) async throws -> Int?
}

extension NameDataManager {
    func fetchNames(context: ModelContext) async throws -> [Name] {
        let descriptor = FetchDescriptor<Name>()
        return try context.fetch(descriptor)
    }

    func addName(_ name: Name, context: ModelContext) async throws {
        context.insert(name)
        try context.save()
    }

    func deleteNames(_ names: [Name], context: ModelContext) async throws {
        for name in names {
            context.delete(name)
        }
        try context.save()
    }

    func updateName(_ name: Name, context: ModelContext) async throws {
        try context.save()
    }

    func getRank(of name: Name, from context: ModelContext) async throws -> Int? {
        let sex = name.sexRawValue
        let descriptor = FetchDescriptor<Name>(
            predicate: #Predicate { $0.sexRawValue == sex },
            sortBy: [
                .init(\.affinityRating, order: .reverse)
            ]
        )
        
        let names = try context.fetch(descriptor)
        
        return names.firstIndex(of: name).map { $0 + 1 }
    }
}
