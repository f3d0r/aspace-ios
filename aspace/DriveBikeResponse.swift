//
//  DriveBikeResponse.swift
//  aspace
//
//  Created by Fedor Paretsky on 10/24/18.
//  Copyright © 2018 aspace, Inc. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let driveBikeResponse = try? newJSONDecoder().decode(DriveBikeResponse.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseDriveBikeResponse { response in
//     if let driveBikeResponse = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

struct DriveBikeResponse: Codable {
    let resInfo: ResInfo?
    let resContent: ResContent?
    
    enum CodingKeys: String, CodingKey {
        case resInfo = "res_info"
        case resContent = "res_content"
    }
}

struct ResContent: Codable {
    let routes: [[ResContentRoute]]?
}

struct ResContentRoute: Codable {
    let name, prettyName: String?
    let origin, dest: Dest?
    let directions: Directions?
    
    enum CodingKeys: String, CodingKey {
        case name
        case prettyName = "pretty_name"
        case origin, dest, directions
    }
}

struct Dest: Codable {
    let meta: Meta?
    let lng, lat: Lat?
}

enum Lat: Codable {
    case double(Double)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Lat.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Lat"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

struct Meta: Codable {
    let id: String?
    let distance: Double?
    let parkingPrice: Int?
    let type: String?
    let drivingTime: Double?
    let name, paymentProcess, address, paymentTypes: String?
    let facilities: String?
    
    enum CodingKeys: String, CodingKey {
        case id, distance
        case parkingPrice = "parking_price"
        case type
        case drivingTime = "driving_time"
        case name
        case paymentProcess = "payment_process"
        case address
        case paymentTypes = "payment_types"
        case facilities
    }
}

struct Directions: Codable {
    let code: String?
    let waypoints: [Waypoint]?
    let routes: [DirectionsRoute]?
}

struct DirectionsRoute: Codable {
    let legs: [Leg]?
    let weightName: String?
    let geometry: Geometry?
    let weight, distance, duration: Double?
    
    enum CodingKeys: String, CodingKey {
        case legs
        case weightName = "weight_name"
        case geometry, weight, distance, duration
    }
}

struct Geometry: Codable {
    let coordinates: [[Double]]?
    let type: TypeEnum?
}

enum TypeEnum: String, Codable {
    case lineString = "LineString"
}

struct Leg: Codable {
    let steps: [Step]?
    let weight, distance: Double?
    let annotation: Annotation?
    let summary: String?
    let duration: Double?
}

struct Annotation: Codable {
    let speed: [Double]?
    let metadata: Metadata?
    let nodes: [Int]?
    let duration, distance, weight: [Double]?
    let datasources: [Int]?
}

struct Metadata: Codable {
    let datasourceNames: [String]?
    
    enum CodingKeys: String, CodingKey {
        case datasourceNames = "datasource_names"
    }
}

struct Step: Codable {
    let intersections: [Intersection]?
    let drivingSide: DrivingSide?
    let geometry: Geometry?
    let duration, distance: Double?
    let name: String?
    let weight: Double?
    let mode: Mode?
    let maneuver: Maneuver?
    let instruction, ref, destinations: String?
    
    enum CodingKeys: String, CodingKey {
        case intersections
        case drivingSide = "driving_side"
        case geometry, duration, distance, name, weight, mode, maneuver, instruction, ref, destinations
    }
}

enum DrivingSide: String, Codable {
    case drivingSideLeft = "left"
    case drivingSideRight = "right"
    case none = "none"
    case slightLeft = "slight left"
    case slightRight = "slight right"
    case straight = "straight"
}

struct Intersection: Codable {
    let out: Int?
    let entry: [Bool]?
    let location: [Double]?
    let bearings: [Int]?
    let intersectionIn: Int?
    let classes: [Class]?
    let lanes: [Lane]?
    
    enum CodingKeys: String, CodingKey {
        case out, entry, location, bearings
        case intersectionIn = "in"
        case classes, lanes
    }
}

enum Class: String, Codable {
    case motorway = "motorway"
    case tunnel = "tunnel"
}

struct Lane: Codable {
    let valid: Bool?
    let indications: [DrivingSide]?
}

struct Maneuver: Codable {
    let bearingAfter, bearingBefore: Int?
    let type: String?
    let location: [Double]?
    let modifier: DrivingSide?
    
    enum CodingKeys: String, CodingKey {
        case bearingAfter = "bearing_after"
        case bearingBefore = "bearing_before"
        case type, location, modifier
    }
}

enum Mode: String, Codable {
    case driving = "driving"
}

struct Waypoint: Codable {
    let hint: String?
    let location: [Double]?
    let name: String?
}

struct ResInfo: Codable {
    let code: Int?
    let codeInfo: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case codeInfo = "code_info"
    }
}

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - Alamofire response handlers

extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            return Result { try newJSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseDriveBikeResponse(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<DriveBikeResponse>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
