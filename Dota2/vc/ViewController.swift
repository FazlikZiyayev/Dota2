//
//  ViewController.swift
//  Dota2
//
//  Created by Fazlik Ziyaev on 08/12/21.
//

import UIKit

// Got from stackverflow to get image from link
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

class ViewController: UIViewController{
    
    private let cellIdentifier = "heroCell"
    private var heroes = [Hero]()
    private let baseUrl = "https://api.opendota.com"
    @IBOutlet weak var collectionViev: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViev.dataSource = self
        
        let url = URL(string: baseUrl + "/api/heroStats")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            if let safeData = data {
                let decoder = JSONDecoder()
                
                do{
                    self.heroes = try decoder.decode([Hero].self, from: safeData)
                }catch {
                    print("Error while loading data  \(error)")
                }
                
                // Switching to main thread
                DispatchQueue.main.async {
                    self.collectionViev.reloadData()
                }
                
                print(self.heroes.count)
            }
        }
        
        task.resume()
    }
}

// extension for using collectionView's data source
extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        heroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionViev.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CustomCollectionViewCell
        
        cell.heroName.text = heroes[indexPath.row].localized_name
        cell.heroImg.downloaded(from: baseUrl + heroes[indexPath.row].img)
        cell.heroImg.layer.cornerRadius = cell.frame.height / 2
        
        return cell
    }
    
     
}

