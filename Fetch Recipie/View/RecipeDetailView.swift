import UIKit
import WebKit

class RecipeDetailView: UIView 
{
    // YouTube WebView
    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    private let replacementImage: UIImageView = {
       let image = UIImageView()
        image.isHidden = true
        return image
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = Colors.textColor
        return label
    }()
    
    private let cuisineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = Colors.textColor
        return label
    }()
    
    private let moreInfoButton: UIButton = {
        let button = UIButton()
        button.setTitle("Click here to learn more", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    private var sourceUrl: String?
    
    init(recipe: RecipeModel) 
    {
        super.init(frame: .zero)
        backgroundColor = Colors.collectionCardBackground
        layer.cornerRadius = 12
        setupUI()
        configure(with: recipe)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() 
    {
        [webView, replacementImage, nameLabel, cuisineLabel, moreInfoButton].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            webView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            
            replacementImage.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            replacementImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            replacementImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            replacementImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            
            nameLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            cuisineLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            cuisineLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cuisineLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            moreInfoButton.topAnchor.constraint(equalTo: cuisineLabel.bottomAnchor, constant: 16),
            moreInfoButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            moreInfoButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        moreInfoButton.addTarget(self, action: #selector(moreInfoTapped), for: .touchUpInside)
    }
    
    private func configure(with recipe: RecipeModel) 
    {
        nameLabel.text = recipe.name
        cuisineLabel.text = recipe.cuisine
        sourceUrl = recipe.sourceUrl
        
        if let youtubeUrl = recipe.youtubeUrl 
        {
            let embedUrl = youtubeUrl.replacingOccurrences(of: "watch?v=", with: "embed/")
            if let url = URL(string: embedUrl) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
        else //No youtubeUrl given from the JSON
        {
            webView.isHidden = true
            replacementImage.isHidden = false
            replacementImage.loadImage(from: recipe.photoUrlLarge ?? recipe.photoUrlSmall ?? "")
        }
        if recipe.sourceUrl == nil
        {
            moreInfoButton.isHidden = true
        }
        
    }
    
    @objc private func moreInfoTapped() 
    {
        if let urlString = sourceUrl, let url = URL(string: urlString)
        {
            UIApplication.shared.open(url)
        }
    }
}
