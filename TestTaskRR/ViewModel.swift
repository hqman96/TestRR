import Foundation

final class PhotosCollectionViewModel {
    
    private var networkDataFetcher = NetworkDataFetcher()
    
    var photos: [UnsplashPhoto]?  {
        didSet {
            photosUpdateHandler?()
        }
    }
    
    var photosUpdateHandler: (() -> Void)?
    
    func fetchImages(searchTerm: String) {
        networkDataFetcher.fetchImages(searchTerm: searchTerm) { [weak self] (searchResults) in
            guard let fetchedPhotos = searchResults else { return }
            self?.photos = fetchedPhotos.results
        }
    }
}
