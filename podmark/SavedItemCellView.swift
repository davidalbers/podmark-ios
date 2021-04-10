import UIKit

class SavedItemCellView: UITableViewCell {
    let title = UILabel()
    let podcastName = UILabel()
    let artwork = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        title.translatesAutoresizingMaskIntoConstraints = false
        podcastName.translatesAutoresizingMaskIntoConstraints = false
        artwork.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(title)
        contentView.addSubview(podcastName)
        contentView.addSubview(artwork)

        NSLayoutConstraint.activate([
            artwork.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            artwork.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            artwork.heightAnchor.constraint(equalToConstant: 64),
            artwork.widthAnchor.constraint(equalToConstant: 64),

            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: artwork.trailingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 16),
            
            podcastName.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            podcastName.leadingAnchor.constraint(equalTo: artwork.trailingAnchor, constant: 16),
            podcastName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 16),
            contentView.bottomAnchor.constraint(equalTo: podcastName.bottomAnchor, constant: 16),
        ])
        
        artwork.layer.borderWidth = 1.0
        artwork.layer.masksToBounds = false
        artwork.layer.borderColor = UIColor(named: "border")?.cgColor
        artwork.layer.cornerRadius = 8
        artwork.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
