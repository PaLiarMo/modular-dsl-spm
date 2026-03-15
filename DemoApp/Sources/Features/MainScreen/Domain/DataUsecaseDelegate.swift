//
//  DataUsecaseDelegate.swift
//  DemoApp
//
//  Created by PaLiarMo on 15.03.2026.
//

public protocol DataUsecaseDelegate {
    func onDataReceived(data: [DomainModel])
    func onDataFailed(error: Error)
}
