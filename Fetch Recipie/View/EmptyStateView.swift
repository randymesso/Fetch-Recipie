import UIKit

class EmptyStateView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.image = UIImage(systemName: "pencil.and.list.clipboard")?.withRenderingMode(.alwaysTemplate)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Try Again", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onRetryTapped: (() -> Void)?
    
    init(title: String, message: String, showRetryButton: Bool = true) {
        super.init(frame: .zero)
        titleLabel.text = title
        messageLabel.text = message
        setupUI(showRetryButton: showRetryButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(showRetryButton: Bool) {
        backgroundColor = .systemBackground
        
        [imageView, titleLabel, messageLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if showRetryButton {
            addSubview(retryButton)
        }
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        if showRetryButton {
            NSLayoutConstraint.activate([
                retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
                retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                retryButton.widthAnchor.constraint(equalToConstant: 120),
                retryButton.heightAnchor.constraint(equalToConstant: 44)
            ])
            
            retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        }
    }
    
    @objc private func retryTapped() {
        onRetryTapped?()
    }
}
