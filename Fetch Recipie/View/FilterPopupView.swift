import UIKit

class FilterPopupView: UIView
{
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Difficulty"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let easyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Easy", for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let mediumButton: UIButton = {
        let button = UIButton()
        button.setTitle("Medium", for: .normal)
        button.backgroundColor = .yellow
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let hardButton: UIButton = {
        let button = UIButton()
        button.setTitle("Hard", for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let applyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Apply Filter", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let clearFilterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear Filter", for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var selectedDifficulty: String?
    var onFilterSelected: ((String) -> Void)?
    private let currentFilter: String?
    
    init(currentFilter: String? = nil) {
        self.currentFilter = currentFilter
        super.init(frame: .zero)
        setupUI()
        highlightCurrentFilter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func highlightCurrentFilter()
    {
        [easyButton, mediumButton, hardButton].forEach { $0.alpha = 0.5 }
        
        switch currentFilter {
        case "Easy":
            easyButton.alpha = 1.0
            selectedDifficulty = "Easy"
        case "Medium":
            mediumButton.alpha = 1.0
            selectedDifficulty = "Medium"
        case "Hard":
            hardButton.alpha = 1.0
            selectedDifficulty = "Hard"
        default:
            break
        }
    }
    
    func setupUI()
    {
        backgroundColor = .white
        layer.cornerRadius = 12
        
        [titleLabel, easyButton, mediumButton, hardButton, applyButton, clearFilterButton].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            easyButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            easyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            easyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            easyButton.heightAnchor.constraint(equalToConstant: 50),
            
            mediumButton.topAnchor.constraint(equalTo: easyButton.bottomAnchor, constant: 20),
            mediumButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mediumButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            mediumButton.heightAnchor.constraint(equalToConstant: 50),
            
            hardButton.topAnchor.constraint(equalTo: mediumButton.bottomAnchor, constant: 20),
            hardButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            hardButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            hardButton.heightAnchor.constraint(equalToConstant: 50),
            
            applyButton.topAnchor.constraint(equalTo: hardButton.bottomAnchor, constant: 30),
            applyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            applyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            applyButton.heightAnchor.constraint(equalToConstant: 50),
            //applyButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            clearFilterButton.topAnchor.constraint(equalTo: applyButton.bottomAnchor, constant: 10),
            clearFilterButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            clearFilterButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            clearFilterButton.heightAnchor.constraint(equalToConstant: 50),
            clearFilterButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
        
        easyButton.addTarget(self, action: #selector(difficultySelected(_:)), for: .touchUpInside)
        mediumButton.addTarget(self, action: #selector(difficultySelected(_:)), for: .touchUpInside)
        hardButton.addTarget(self, action: #selector(difficultySelected(_:)), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyFilterTapped), for: .touchUpInside)
        clearFilterButton.addTarget(self, action: #selector(clearFilterTapped), for: .touchUpInside)
    }
    
    @objc private func difficultySelected(_ sender: UIButton)
    {
        // Reset all buttons
        [easyButton, mediumButton, hardButton].forEach { $0.alpha = 0.5 }
        // Highlight selected button
        sender.alpha = 1.0
        selectedDifficulty = sender.title(for: .normal)
    }
    
    @objc private func applyFilterTapped()
    {
        if let difficulty = selectedDifficulty {
            onFilterSelected?(difficulty)
        }
    }
    
    @objc private func clearFilterTapped()
    {
        selectedDifficulty = nil
        [easyButton, mediumButton, hardButton].forEach { $0.alpha = 0.5 }
        onFilterSelected?("Clear")
    }
}
