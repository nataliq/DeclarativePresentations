import Foundation
import UIKit

public class ActionViewController: UIViewController {
    let buttonTitle: String
    public var onAction: (() -> Void)?

    public init(buttonTitle: String) {
        self.buttonTitle = buttonTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 8
        button.backgroundColor = UIColor(red: 3/255, green: 65/255, blue: 89/255, alpha: 1.0)
        button.setTitle(buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
    }

    @objc private func actionButtonTapped() {
        onAction?()
    }
}
