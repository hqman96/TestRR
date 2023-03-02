import UIKit

final class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var spinnerViewHeight: NSLayoutConstraint!
    
    private var toggle = false
    private let sectionInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    let viewModel = PhotosCollectionViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupCollectionView()
        setupFadeView()
        setupSearchView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func bindViewModel() {
        viewModel.photosUpdateHandler = {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func setupCollectionView() {
        collectionView.isHidden = true
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .automatic
    }
    
    private func setupFadeView() {
        fadeView.backgroundColor = .black.withAlphaComponent(0.4)
        fadeView.alpha = 1
        fadeView.isHidden = true
        view.bringSubviewToFront(fadeView)
    }
    
    private func setupSearchView() {
        searchViewHeight.constant = UIScreen.main.bounds.height * 0.41
        searchView.backgroundColor = .white
        setupSearchBar()
        setupSearchButton()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.updateSearchBar(color: UIColor(red: 0.933, green: 0.933, blue: 0.933, alpha: 1), height: 48, radius: 12)
        searchBar.setPositionAdjustment(.init(horizontal: 6, vertical: 0), for: .search)
        searchBar.setPositionAdjustment(.init(horizontal: -6, vertical: 0), for: .clear)
    }
    
    private func setupSearchButton() {
        searchButton.layer.backgroundColor = UIColor(red: 0.922, green: 0.047, blue: 0.047, alpha: 1).cgColor
        searchButton.layer.cornerRadius = 12
        searchButton.setTitle("Искать", for: .normal)
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc private func buttonAction() {
        guard let text = searchBar.text, !text.isEmpty else { return }
        self.toggle = true
        searchViewHeight.constant = 118
        spinnerViewHeight.constant = UIScreen.main.bounds.height -  searchViewHeight.constant
        activityIndicator.startAnimating()
        spinnerView.isHidden = false
        self.view.bringSubviewToFront(spinnerView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.spinnerView.isHidden = true
        }
        
        viewModel.fetchImages(searchTerm: text)
        
        collectionView.isHidden = false
        collectionView.reloadData()
    }
    
    @objc private func keyboardWillShow() {
        if toggle {
            fadeView.isHidden = false
        }
    }
    
    @objc private func keyboardWillHide() {
        fadeView.isHidden = true
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photos = viewModel.photos?.count, photos > 0 {
            return photos
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        if let photos = viewModel.photos, !photos.isEmpty {
            cell.unsplashPhoto = photos[indexPath.item]
        } else {
            cell.photoImageView.layer.borderWidth = 0
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let photos = viewModel.photos?.count, photos > 0 {
            let width = (collectionView.frame.width - 32 - 16)/3
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: collectionView.frame.width - 32, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}

extension UISearchBar {
    func updateSearchBar(color: UIColor, height: CGFloat, radius: CGFloat = 8.0) {
        let image: UIImage? = UIImage.imageWithColor(color: color, size: CGSize(width: 1, height: height))
        setSearchFieldBackgroundImage(image, for: .normal)
        for subview in self.subviews {
            for subSubViews in subview.subviews {
                if #available(iOS 13.0, *) {
                    for child in subSubViews.subviews {
                        if let textField = child as? UISearchTextField {
                            textField.layer.cornerRadius = radius
                            textField.clipsToBounds = true
                        }
                    }
                    continue
                }
                if let textField = subSubViews as? UITextField {
                    textField.layer.cornerRadius = radius
                    textField.clipsToBounds = true
                }
            }
        }
    }
}

private extension UIImage {
    static func imageWithColor(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
}
