import UIKit

class FolderCellView: UITableViewCell {

    let folderName = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()

        folderName.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(folderName)
       
        folderName.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true

        folderName.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}
