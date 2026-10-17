//
//  ParticlesComponentsTests.swift
//  FirebladeECSDemo
//

import FirebladeECS
import Foundation
@testable import Particles
import Testing

@Suite struct ParticlesComponentsTests {
    @Test func snapshotRoundTripRestoresEntitiesAndComponents() throws {
        let nexus = Nexus()
        try nexus.register([Name.self, Position.self, Color.self])
        nexus.createEntities(count: 3) { ctx in
            Name("\(ctx.index)")
            Position(x: Int32(ctx.index), y: Int32(ctx.index * 2))
            Color()
        }

        var encoder = JSONEncoder()
        let data = try nexus.encodeSnapshot(using: &encoder, handling: .throwError)

        let restored = Nexus()
        try restored.register([Name.self, Position.self, Color.self])
        var decoder = JSONDecoder()
        try restored.restoreSnapshot(from: data, using: &decoder)

        #expect(restored.numEntities == 3)
        // restoring keeps the entity identifiers
        for (entity, name, position, color) in nexus.family(requiresAll: Name.self, Position.self, Color.self)
            .entityAndComponents {
            let copy = restored.entity(from: entity.identifier)
            #expect(copy.get(Name.self)?.name == name.name)
            let copyPosition = try #require(copy.get(Position.self))
            #expect((copyPosition.x, copyPosition.y) == (position.x, position.y))
            let copyColor = try #require(copy.get(Color.self))
            #expect((copyColor.r, copyColor.g, copyColor.b) == (color.r, color.g, color.b))
        }
    }

    @Test func restoreAfterDestroyingAllEntitiesRepopulatesExistingFamilies() throws {
        // mirrors the `k` (save) and `l` (restore) keys of the demo
        let nexus = Nexus()
        try nexus.register([Name.self, Position.self, Color.self])
        let family = nexus.family(requiresAll: Position.self, Color.self)
        nexus.createEntities(count: 100) { ctx in
            Name("\(ctx.index)")
            Position(x: 1, y: 2)
            Color()
        }
        var encoder = JSONEncoder()
        let data = try nexus.encodeSnapshot(using: &encoder, handling: .skip)

        nexus.createEntities(count: 50) { _ in Position(x: 0, y: 0) }
        Array(AnyIterator(nexus.makeEntitiesIterator())).forEach { $0.destroy() }
        #expect(nexus.numEntities == 0)

        var decoder = JSONDecoder()
        try nexus.restoreSnapshot(from: data, using: &decoder)

        #expect(nexus.numEntities == 100)
        #expect(family.count == 100)
        #expect(family.allSatisfy { position, _ in (position.x, position.y) == (1, 2) })
        // new entities don't collide with restored identifiers
        let entity = nexus.createEntity(with: Position(x: 9, y: 9))
        #expect(nexus.numEntities == 101)
        #expect(entity.get(Position.self)?.x == 9)
    }

    @Test func cloneCopiesComponentsIntoNewInstances() throws {
        let nexus = Nexus()
        let entity = nexus.createEntity(with: Name("origin"), Position(x: 4, y: 2), Color())

        let clone = try entity.clone()

        #expect(nexus.numEntities == 2)
        let original = try #require(entity.get(Position.self))
        let copy = try #require(clone.get(Position.self))
        #expect(original !== copy)
        #expect((copy.x, copy.y) == (4, 2))
        #expect(clone.get(Name.self)?.name == "origin")
    }

    @Test func macroGeneratesDefaultInitializerAndInspection() {
        let position = Position()
        #expect((position.x, position.y) == (0, 0))
        #expect(Position.componentProperties.map(\.name) == ["x", "y"])
    }
}
