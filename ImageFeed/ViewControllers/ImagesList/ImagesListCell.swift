//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 14.11.2025.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
 
    // MARK: - Outlets
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
}
