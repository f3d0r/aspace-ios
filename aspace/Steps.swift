/* 
Copyright (c) 2018 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Steps : Codable {
	let intersections : [Intersections]?
	let driving_side : String?
	let geometry : Geometry?
	let duration : Double?
	let distance : Int?
	let name : String?
	let weight : Double?
	let mode : String?
	let maneuver : Maneuver?
	let instruction : String?

	enum CodingKeys: String, CodingKey {

		case intersections = "intersections"
		case driving_side = "driving_side"
		case geometry = "geometry"
		case duration = "duration"
		case distance = "distance"
		case name = "name"
		case weight = "weight"
		case mode = "mode"
		case maneuver = "maneuver"
		case instruction = "instruction"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		intersections = try values.decodeIfPresent([Intersections].self, forKey: .intersections)
		driving_side = try values.decodeIfPresent(String.self, forKey: .driving_side)
		geometry = try values.decodeIfPresent(Geometry.self, forKey: .geometry)
		duration = try values.decodeIfPresent(Double.self, forKey: .duration)
		distance = try values.decodeIfPresent(Int.self, forKey: .distance)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		weight = try values.decodeIfPresent(Double.self, forKey: .weight)
		mode = try values.decodeIfPresent(String.self, forKey: .mode)
		maneuver = try values.decodeIfPresent(Maneuver.self, forKey: .maneuver)
		instruction = try values.decodeIfPresent(String.self, forKey: .instruction)
	}

}