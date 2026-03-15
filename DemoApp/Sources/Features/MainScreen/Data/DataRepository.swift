//
//  DataRepository.swift
//  DemoApp
//
//  Created by PaLiarMo on 15.03.2026.
//
//import Alamofire
import Foundation
import Networking

public protocol DataRepository{
    func fetchData(completion: @escaping ([DataModel]?, Error?) -> Void)
}

class DataRepositoryImpl: DataRepository {
    func fetchData(completion: @escaping ([DataModel]?, Error?) -> Void) {
        Networking.fetchDataList<DataModel> { data, error in
            completion(data, error)
        }
    }
}

// This factory is provided only for demo purposes.
// In a real application you would typically construct and inject the repository
// using your own Dependency Injection setup.
public func makeDataRepository() -> DataRepository {
    return DataRepositoryImpl()
}
