//
//  GetAddress.swift
//  MyMemory
//
//  Created by 김태훈 on 1/16/24.
//

import Foundation
import KakaoMapsSDK
//MARK: - 좌표 -> 주소 변환하는 싱글톤입니다. 사용방법은 GetAddress.shared.getUserLocation(location: .init(longitude: Double, latitude: Double) 입니다.
class GetAddress{
    static let shared = GetAddress()
    private let restKey: String? = Bundle.main.object(forInfoDictionaryKey: "REST_API") as? String
    func getAddressStr(location: MapPoint) async -> String{
        let dto = await getUserLocation(location: location)
        let roadAddressList = dto?.documents.map{$0.roadAddress}.first
        let addressList = dto?.documents.map{$0.address}.first
        return roadAddressList??.addressName ?? (addressList?.addressName ?? "")
    }
    private func getUserLocation(location: MapPoint) async -> AdressDTO?{
        guard let key = restKey else { return nil}
        var failedData: Data? = nil
        
        var findURL: String {
            return "https://dapi.kakao.com/v2/local/geo/coord2address.json?x=\(location.wgsCoord.longitude)&y=\(location.wgsCoord.latitude)&input_coord=WGS84"
        }
        var headers: [String: String]? {
            return ["Authorization" : "KakaoAK \(key)"]
        }
        do {
            var urlRequest = URLRequest(url: URL(string: findURL)!)
            urlRequest.httpMethod = "GET"
            if let headers = headers {
                for (key, value) in headers {
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            }
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                return nil
            }
            if (200...299).contains( httpResponse.statusCode ) {
                failedData = data
                
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(AdressDTO.self, from: data)
                failedData = nil
                
                return decodedResponse
                
            }
        }catch let decodingError as DecodingError {
            if let failed = failedData {
                do {
                    let json = try JSONSerialization.jsonObject(with: failed, options: []) as? [String: Any]
                    print("JSON Response: \(json ?? [:])")
                    failedData = nil
                    // Try decoding your model here
                } catch let error {
                    failedData = nil
                    print("Error decoding JSON: \(error)")
                }
            }
        } catch {
            return nil
        }
        return nil
    }
}
