//
//  DetailViewController.swift
//  DemoApp
//
//  Created by PaLiarMo on 15.03.2026.
//
import UIKit

class DetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupThankYouLabel()
    }

    private func setupThankYouLabel() {
        let thankYouLabel = UILabel()
        thankYouLabel.translatesAutoresizingMaskIntoConstraints = false
        thankYouLabel.text = "✨ Thank you! ✨\n for\n✨ exploring this topic! ✨"
        thankYouLabel.textAlignment = .center
        thankYouLabel.numberOfLines = 0
        thankYouLabel.font = .systemFont(ofSize: 28, weight: .bold)
        thankYouLabel.layer.shadowColor = UIColor.black.cgColor
        thankYouLabel.layer.shadowOpacity = 0.2
        thankYouLabel.layer.shadowRadius = 4
        thankYouLabel.layer.shadowOffset = CGSize(width: 0, height: 2)

        view.addSubview(thankYouLabel)

        NSLayoutConstraint.activate([
            thankYouLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thankYouLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            thankYouLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            thankYouLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }
}

public func makeDetailViewController() -> UIViewController {
    DetailViewController()
}
