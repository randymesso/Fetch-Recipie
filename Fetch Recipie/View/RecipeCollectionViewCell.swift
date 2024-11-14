import UIKit

class RecipeCollectionViewCell: UICollectionViewCell
{
    let difficultyTagView = DifficultyTagView()
    
    let coverImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let foodName: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textColor
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let cuisineType: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textColor
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let cookingTime: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textColor
        label.text = "Cooking time: "
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let cookingMinutes: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textColor
        //label.textAlignment =
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        backgroundColor = Colors.collectionCardBackground
        self.isUserInteractionEnabled = true
        addSubviews()
        configureViews()
        roundCorners()
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews()
    {
        [coverImage, difficultyTagView,foodName, cuisineType, cookingTime, cookingMinutes].forEach {
            addSubview($0)
        }
    }
    
    func configureViews()
    {
        let padding: CGFloat = 8
        
        [coverImage, difficultyTagView,foodName, cuisineType, cookingTime, cookingMinutes].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            coverImage.topAnchor.constraint(equalTo: topAnchor),
            coverImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverImage.heightAnchor.constraint(equalToConstant: frame.height * 0.65),
            
            difficultyTagView.topAnchor.constraint(equalTo: topAnchor),
            difficultyTagView.leadingAnchor.constraint(equalTo: leadingAnchor),
            difficultyTagView.widthAnchor.constraint(equalToConstant: frame.width * 0.40),
            difficultyTagView.heightAnchor.constraint(equalToConstant: 16),
            
            foodName.topAnchor.constraint(equalTo: coverImage.bottomAnchor, constant: padding),
            foodName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            foodName.trailingAnchor.constraint(equalTo: centerXAnchor),
            foodName.heightAnchor.constraint(equalToConstant: frame.height * 0.15),
            
            cuisineType.topAnchor.constraint(equalTo: coverImage.bottomAnchor, constant: padding),
            cuisineType.leadingAnchor.constraint(equalTo: foodName.trailingAnchor, constant: padding),
            cuisineType.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            cuisineType.heightAnchor.constraint(equalToConstant: frame.height * 0.15),
            
            cookingTime.topAnchor.constraint(equalTo: foodName.bottomAnchor, constant: padding),
            cookingTime.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            cookingTime.trailingAnchor.constraint(equalTo: centerXAnchor,constant: padding),
            
            cookingMinutes.topAnchor.constraint(equalTo: cuisineType.bottomAnchor, constant: padding),
            cookingMinutes.leadingAnchor.constraint(equalTo: cookingTime.trailingAnchor),
            cookingMinutes.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }
    
    func configure(with recipe: RecipeModel)
    {
        coverImage.loadImage(from: recipe.photoUrlLarge ?? recipe.photoUrlSmall ?? "")
        difficultyTagView.title.text = recipe.difficulty ?? "Unknown"
        foodName.text = "\(recipe.name)  "
        cuisineType.text = "(\(recipe.cuisine))"
        cookingMinutes.text = "\(recipe.cookingTime ?? 0) mins"
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        coverImage.image = nil // Clear the image
    }
    
    private func roundCorners()   //Make round corners for the UIViews
    {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        layer.cornerRadius = 12  // Match contentView corner radius
        coverImage.layer.cornerRadius = 12
        coverImage.layer.maskedCorners =
        [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        coverImage.layer.masksToBounds = true
        difficultyTagView.layer.cornerRadius = 12
        difficultyTagView.layer.maskedCorners =
        [
            .layerMinXMinYCorner
        ]
        difficultyTagView.layer.masksToBounds = true
    }
}

