//
//	Avatar.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class Avatar : NSObject, NSCoding, Mappable{

	var height : Int?
	var url : String?


	class func newInstance(map: Map) -> Mappable?{
		return Avatar()
	}
	required init?(map: Map){}
	private override init(){}

	func mapping(map: Map)
	{
		height <- map["height"]
		url <- map["url"]
		
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         height = aDecoder.decodeObject(forKey: "height") as? Int
         url = aDecoder.decodeObject(forKey: "url") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if height != nil{
			aCoder.encode(height, forKey: "height")
		}
		if url != nil{
			aCoder.encode(url, forKey: "url")
		}

	}

}