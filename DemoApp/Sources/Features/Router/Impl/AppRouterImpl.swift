//
//  AppRouterImpl.swift
//  DemoApp
//
//  Created by PaLiarMo on 14.03.2026.
//
import Router_Api
import UIKit
import DI
import MainScreen_Presentation
import DetailScreen_Presentation

public func makeAppRouter(navigationController: UINavigationController) -> AppRouter {
    AppRouterImpl(navigationController: navigationController)
}

final class AppRouterImpl: AppRouter {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func showHome() {
        let viewController = makeMainScreenViewController(router: self)
        navigationController.setViewControllers([viewController], animated: true)
    }

    func showDetail(id: Int) {
        let viewController = makeDetailViewController()
        viewController.title = "Detail \(id)"
        navigationController.pushViewController(viewController, animated: true)
    }
}
