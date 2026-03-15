//
//  DataUsecase.swift
//  DemoApp
//
//  Created by PaLiarMo on 15.03.2026.
//
import MainScreen_Data
import Foundation

public protocol DataUsecase {
    func fetchData(completion: @escaping ([DomainModel]?, Error?) -> Void)
}

class DataUsecaseImpl: DataUsecase {
    var repository: DataRepository = makeDataRepository()
    
    func fetchData(completion: @escaping([DomainModel]?, (any Error)?) -> Void) {
        self.repository.fetchData { data, error in
            completion(data?.map { $0.toDomain()}, error)
            
            
        }
    }
}

// This factory is provided only for demo purposes.
// In a real application you would typically construct and inject the repository
// using your own Dependency Injection setup.
public func makeDataUsecase() -> DataUsecase {
    DataUsecaseImpl()
}
