//
//  Mapper.swift
//  DemoApp
//
//  Created by PaLiarMo on 15.03.2026.
//
import MainScreen_Data

extension DataModel {
    func toDomain() -> DomainModel {
        .init(id: id, title: title, body: body)
    }
}
