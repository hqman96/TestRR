import UIKit
import SDWebImage

final class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    static let reuseID = "CollectionViewCell"
    
    var unsplashPhoto: UnsplashPhoto! {
            didSet {
                let photoUrl = unsplashPhoto.urls["regular"]
                guard let imageUrl = photoUrl, let url = URL(string: imageUrl) else { return }
                photoImageView.sd_setImage(with: url, completed: nil)
            }
        }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.backgroundColor = .white
        photoImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        photoImageView.layer.cornerRadius = 4
        photoImageView.layer.borderWidth = 1
        photoImageView.layer.borderColor = UIColor(red: 0.922, green: 0.922, blue: 0.922, alpha: 1).cgColor

    }
}
