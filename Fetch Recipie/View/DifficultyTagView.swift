import UIKit

class DifficultyTagView: UIView
{
    let title: UILabel = {
       let label = UILabel()
        label.text = "Hard"
        label.textColor = Colors.textColor
        return label
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        configureTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTitle()
    {
        addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
}
