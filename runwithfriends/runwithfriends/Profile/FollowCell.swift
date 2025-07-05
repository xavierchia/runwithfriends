import UIKit

class FollowCell: UITableViewCell {
    enum FollowAction {
        case follow
        case unfollow
    }
    
    // MARK: - Properties
    static let identifier = "FollowCell"
        
    // MARK: - Action Callback
    var buttonTapHandler: ((FollowAction) -> Void)?
    
    var isFollowing = false {
        didSet {
            if isFollowing {
                actionButton.setTitle("Unfollow", for: .normal)
                actionButton.setTitleColor(.baseText, for: .normal)
                actionButton.backgroundColor = .clear
                actionButton.layer.cornerRadius = 5
                actionButton.layer.borderWidth = 1.5
                actionButton.layer.borderColor = UIColor.baseText.cgColor
            } else {
                actionButton.setTitle("Follow", for: .normal)
                actionButton.setTitleColor(.cream, for: .normal)
                actionButton.backgroundColor = .accent
                actionButton.layer.cornerRadius = 5
                actionButton.layer.borderWidth = 0
                actionButton.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    // Left label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.QuicksandMedium(size: 17)
        label.textColor = .baseText
        label.numberOfLines = 1
        return label
    }()
    
    // Right button
    private let actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Action", for: .normal)
        button.titleLabel?.font = UIFont.QuicksandMedium(size: 17)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return button
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    // Required by UIKit but will never be used since we're not using Interface Builder
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = .cream
        
        // Add subviews
        contentView.addSubview(titleLabel)
        contentView.addSubview(actionButton)
        
        // Set constraints
        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -12),
            
            // Action button constraints
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 36),
            actionButton.widthAnchor.constraint(equalToConstant: 105)
        ])
        
        // Add button target
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Public Methods
    func configure(title: String, isFollowing: Bool) {
        titleLabel.text = title
        self.isFollowing = isFollowing
        
        if title == "Loading..." {
            actionButton.isHidden = true
        } else {
            actionButton.isHidden = false
        }
    }
    
    // MARK: - Actions
    @objc private func actionButtonTapped() {
        let followAction: FollowAction = isFollowing ? .unfollow : .follow
        buttonTapHandler?(followAction)
    }
    
    // MARK: - Cell Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        actionButton.setTitle("", for: .normal)
        buttonTapHandler = nil
        actionButton.isHidden = false
    }
}
