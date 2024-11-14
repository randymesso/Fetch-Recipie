import UIKit

class TopDisplayView: UIView
{
    let searchTextBox: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search by name or cuisine type"
        search.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search by name or cuisine type",
            attributes: [NSAttributedString.Key.foregroundColor: Colors.textColor]
        )
        // Change magnifying glass (search icon) color
        let searchIconView = search.searchTextField.leftView as? UIImageView
        searchIconView?.tintColor = .black
        search.searchTextField.textColor = Colors.textColor
        search.backgroundImage = UIImage()
        search.backgroundColor = .clear
        search.searchBarStyle = .minimal  // Apply a minimal style for a cleaner look
        search.showsCancelButton = true
        search.tintColor = Colors.textColor
        return search
    }()
    
    let recipeCounter: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textColor
        label.layer.opacity = 0.70
        return label
    }()
    
    let filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Filter", for: .normal)
        button.setTitleColor(Colors.textColor, for: .normal)
        button.backgroundColor = Colors.buttonColor
        button.layer.cornerRadius = 15
        return button
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        addSubviews()
        configureViews()
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews()
    {
        [searchTextBox, recipeCounter, filterButton].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func configureViews()
    {
        let padding: CGFloat = 8
        
        NSLayoutConstraint.activate([
            searchTextBox.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            searchTextBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            searchTextBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            
            recipeCounter.topAnchor.constraint(equalTo: searchTextBox.bottomAnchor, constant: padding * 2),
            recipeCounter.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding * 2),
            
            filterButton.topAnchor.constraint(equalTo: searchTextBox.bottomAnchor, constant: padding),
            filterButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            filterButton.widthAnchor.constraint(equalTo: filterButton.heightAnchor, multiplier: 2)
        ])
        
    }
    
}
