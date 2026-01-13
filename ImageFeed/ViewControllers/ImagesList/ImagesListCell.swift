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
 
    // MARK: - Outlets
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
        setIsLiked(false)
        likeButton.isEnabled = true
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        likeButton.setImage(image, for: .normal)
    }
    
    func setLikeEnabled(_ enabled: Bool) {
        likeButton.isEnabled = enabled
    }
}

