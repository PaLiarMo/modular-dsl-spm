//
//  MainScreenPresenter.swift
//  DemoApp
//
//  Created by PaLiarMo on 15.03.2026.
//
import MainScreen_Domain
import Router_Api

protocol MainScreenPresenter {
    func fetchData()
    func openDetailScreen(id: Int)
}


class MainScreenPresenterImpl: MainScreenPresenter {
    let router: AppRouter
    let useCase: DataUsecase
    var delegate: DataUsecaseDelegate
    
    init(_ router: AppRouter, useCase: DataUsecase, delegate: DataUsecaseDelegate) {
        self.router = router
        self.useCase = useCase
        self.delegate = delegate
    }
    
    func fetchData() {
        useCase.fetchData { data, error in
            if let data {
                self.delegate.onDataReceived(data: data)
            } else if let error {
                self.delegate.onDataFailed(error: error)
            }
        }
    }
    
    func openDetailScreen(id: Int) {
        router.showDetail(id: id)
    }
}

// This factory is provided only for demo purposes.
// In a real application you would typically construct and inject the repository
// using your own Dependency Injection setup.
func mainScreenPresenter(_ router: AppRouter, delegate: DataUsecaseDelegate) -> MainScreenPresenter {
    return MainScreenPresenterImpl(router, useCase: makeDataUsecase(), delegate: delegate)
}
