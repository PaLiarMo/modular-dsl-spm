//
//  MainScreenViewController.swift
//  DemoApp
//
//  Created by PaLiarMo on 14.03.2026.
//
import UIKit
import MainScreen_Domain
import Router_Api
import UI
import Resources

class MainScreenViewController: UIViewController {
    var presenter: MainScreenPresenter? = nil

    private var items: [DomainModel] = []

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        return tableView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let errorView: UIErrorView = {
        let view = UIErrorView(image: R.images.failed, message: "Could not load data.")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Main Screen"
        setupUI()
        showLoadingState()
        presenter?.fetchData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            errorView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func showLoadingState() {
        tableView.isHidden = true
        errorView.isHidden = true
        loadingIndicator.startAnimating()
    }

    private func showContentState() {
        loadingIndicator.stopAnimating()
        errorView.isHidden = true
        tableView.isHidden = false
    }

    private func showErrorState() {
        loadingIndicator.stopAnimating()
        tableView.isHidden = true
        errorView.isHidden = false
    }
}
extension MainScreenViewController: DataUsecaseDelegate {
    func onDataReceived(data: [DomainModel]) {
        DispatchQueue.main.async {
            self.items = data
            self.tableView.reloadData()
            self.showContentState()
        }
    }

    func onDataFailed(error: any Error) {
        DispatchQueue.main.async {
            self.showErrorState()
        }
    }
}

extension MainScreenViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.row]
        var configuration = cell.defaultContentConfiguration()
        configuration.text = item.title
        configuration.secondaryText = item.body
        configuration.secondaryTextProperties.numberOfLines = 3
        cell.contentConfiguration = configuration
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        presenter?.openDetailScreen(id: item.id)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// This factory is provided only for demo purposes.
// In a real application you would typically construct and inject the repository
// using your own Dependency Injection setup.
public func makeMainScreenViewController(router: AppRouter) -> UIViewController {
    let vc = MainScreenViewController()
    vc.presenter = mainScreenPresenter(router, delegate: vc)
    return vc
}
