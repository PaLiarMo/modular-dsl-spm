//
//  DataModel.swift
//  DemoApp
//
//  Created by PaLiarMo on 15.03.2026.
//

public struct DataModel: Decodable {
    public let id: Int
    let userId: Int
    public let title: String
    public let body: String
}
