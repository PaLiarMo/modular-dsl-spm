import Alamofire
import Foundation


public class Networking {
    public static func fetchDataList<T: Decodable>(completion: @escaping ([T]?, Error?) -> Void) {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        AF.request(url).validate().responseDecodable(of: [T].self) { response in
            switch response.result {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
