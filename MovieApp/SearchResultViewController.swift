//
//  SearchResultViewController.swift
//  MovieApp
//
//  Created by 小野 拓人 on 2022/06/03.
//

import UIKit
import Moya
import RealmSwift

class SearchResultViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let realm = try! Realm()
    var movieArray: [MovieModel.Result] = []
    var search :MovieModel!
    var searchText :String!
    // セルのサイドの余白の比率(XD参照)
    private let sideMarginRatio: CGFloat = 0.06
    // セル同士の余白
    private let itemSpacing: CGFloat = 16
    // 1列に表示するセルの数
    private let itemPerWidth: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //カスタムセルの登録
        let nib = UINib(nibName: "MovieCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "MovieCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        //                //
        //        layout.itemSize = CGSize(width: collectionView.frame.width / 4, height: collectionView.frame.height / 6)
        //     layout.minimumInteritemSpacing =
        //
        collectionView.collectionViewLayout = layout
        //        let layout = UICollectionViewFlowLayout()
        //               layout.itemSize = CGSize(width: 50, height: 100)
        //               collectionView.collectionViewLayout = layout
    }
    
    //MARK: - LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let provider = MoyaProvider<API>()
        if let query:String = searchText {
            provider.request(.search(query: query)) { (result) in
                switch result {
                case .success(let response):
                    let data = response.data
                    self.search = try! JSONDecoder().decode(MovieModel.self, from: data)
                    self.movieArray = self.search.results
                    self.collectionView.reloadData()
                    print(self.movieArray)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.setMovie(search: movieArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movieArray[indexPath.row]
        let movieInfo = MovieInfo()
        let movieDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "goToMovieDetail") as! MovieDetailViewController
//        if movie.id == MovieInfo.id {
//            
//        }
        movieDetailViewController.movieInfo = movieInfo
        movieDetailViewController.movie = movie
        self.navigationController?.pushViewController(movieDetailViewController, animated: true)
    }
}
//MARK: - UICollectionViewDelegateFlowLayout
extension SearchResultViewController: UICollectionViewDelegateFlowLayout {
    /// セルのサイズ指定
    ///
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - collectionViewLayout: UICollectionViewLayout
    ///   - indexPath: IndexPath
    /// - Returns: セルのサイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpace = self.collectionView.frame.width / (self.collectionView.frame.width * self.sideMarginRatio) * (self.itemPerWidth + 1)
        let itemSizeWidth = self.collectionView.frame.width - itemSpace
        let width = itemSizeWidth / 2
        // XDの比率に合わせるため(height = width - 7)になるように設定
        return CGSize(width: width, height: width * 1.5)
    }
    /// 各カスタムセル外枠の余白
    ///
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - collectionViewLayout: UICollectionViewLayout
    ///   - section: Int
    /// - Returns: UIEdgeInsets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let space = self.collectionView.frame.width / (self.collectionView.frame.width * self.sideMarginRatio)
        return UIEdgeInsets(top: 15, left: space * 1.2, bottom: 16, right: space * 1.2)
    }
}
