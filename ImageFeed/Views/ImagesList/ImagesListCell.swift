//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 14.11.2025.
//
import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
 
    // MARK: - UI
    
    let cellImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let likeButton: UIButton = {
        let b = UIButton(type: .custom)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let dateLabel: UILabel = {
        let l = UILabel()
        l.textColor = .yapWhite
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cellImage)
        contentView.addSubview(likeButton)
        contentView.addSubview(dateLabel)
        
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        NSLayoutConstraint.activate([
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top),
            cellImage.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -4)
        ])
        
        NSLayoutConstraint.activate([
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellImage.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8),
        ])
        
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.imageListCellDidTapLike(self)
        }
        likeButton.addAction(action, for: .touchUpInside)
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
        setIsLiked(false)
        likeButton.isEnabled = true
    }
    
    // MARK: - API
    
    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        likeButton.setImage(image, for: .normal)
        likeButton.accessibilityIdentifier = isLiked ? "like button on" : "like button off"
    }
    
    func setLikeEnabled(_ enabled: Bool) {
        likeButton.isEnabled = enabled
    }
}
