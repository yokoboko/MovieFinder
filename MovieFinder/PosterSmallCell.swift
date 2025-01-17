//
//  PosterSmallCell.swift
//  MovieFinder
//
//  Created by Yosif Iliev on 27.08.19.
//  Copyright © 2019 Yosif Iliev. All rights reserved.
//

import UIKit
import Nuke

class PosterSmallCell: UICollectionViewCell, PosterCell {

    var imageView: UIImageView = UIImageView()
    var titleLabel: UILabel!
    var genresLabel: UILabel!
    var ratingLabel: UIPaddedLabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {

        let shadowImage = UIImage(named: "shadow")?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 33, bottom: 39, right: 33), resizingMode: .stretch)
        let imageShadowView = UIImageView(image: shadowImage)
        imageShadowView.contentMode = .scaleToFill
        imageShadowView.translatesAutoresizingMaskIntoConstraints = false
        imageShadowView.isUserInteractionEnabled = false
        imageShadowView.setContentHuggingPriority(.init(1), for: .horizontal)
        imageShadowView.setContentHuggingPriority(.init(1), for: .vertical)
        imageShadowView.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        imageShadowView.setContentCompressionResistancePriority(.init(1), for: .vertical)
        contentView.addSubview(imageShadowView)

        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.init(2), for: .horizontal)
        imageView.setContentHuggingPriority(.init(2), for: .vertical)
        imageView.setContentCompressionResistancePriority(.init(2), for: .horizontal)
        imageView.setContentCompressionResistancePriority(.init(2), for: .vertical)
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)

        titleLabel = UILabel()
        titleLabel.textColor = UIColor.movieFinder.secondary
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        genresLabel = UILabel()
        genresLabel.textColor = UIColor.movieFinder.tertiery
        genresLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.light)
        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(genresLabel)

        ratingLabel = UIPaddedLabel()
        ratingLabel.textColor = UIColor.movieFinder.primary
        ratingLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.backgroundColor = UIColor(netHex: 0xFFb10A)
        ratingLabel.layer.cornerRadius = 9
        ratingLabel.clipsToBounds = true
        ratingLabel.leftInset = 8
        ratingLabel.rightInset = 8
        contentView.addSubview(ratingLabel)
       
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: genresLabel.topAnchor, constant: 0),
            
            genresLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            genresLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            genresLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -38),

            imageShadowView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -14),
            imageShadowView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 38),
            imageShadowView.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: -27),
            imageShadowView.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: 27),
            
            ratingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            ratingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -7),
            ratingLabel.heightAnchor.constraint(equalToConstant: 18)
            ])
    }
    
    override func prepareForReuse() {
        isHidden = false
        imageView.image = nil
    }
    
    private func loadImage(imageURL: URL) {
        Nuke.loadImage(with: imageURL,
                       options: ImageLoadingOptions(transition: .fadeIn(duration: 0.33)),
                       into: imageView)
    }

    func setData(title: String, genreNames: [String], rating: Double?, posterURL: URL?) {

        titleLabel.text = title
        genresLabel.text = genreNames.isEmpty ? " " : genreNames.joined(separator: ", ")
        if let rating = rating, rating != 0.0 {
            ratingLabel.text = String(rating)
            ratingLabel.isHidden = false
        } else {
            ratingLabel.isHidden = true
        }
        if let posterURL = posterURL {
            loadImage(imageURL: posterURL)
        }
    }
}

