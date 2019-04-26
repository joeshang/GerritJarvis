//
//	Message.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class Message : NSObject, NSCoding, Mappable{

	var revisionNumber : Int?
	var author : Author?
	var date : String?
	var id : String?
	var message : String?


	class func newInstance(map: Map) -> Mappable?{
		return Message()
	}
	required init?(map: Map){}
	private override init(){}

	func mapping(map: Map)
	{
		revisionNumber <- map["_revision_number"]
		author <- map["author"]
		date <- map["date"]
		id <- map["id"]
		message <- map["message"]
		
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         revisionNumber = aDecoder.decodeObject(forKey: "_revision_number") as? Int
         author = aDecoder.decodeObject(forKey: "author") as? Author
         date = aDecoder.decodeObject(forKey: "date") as? String
         id = aDecoder.decodeObject(forKey: "id") as? String
         message = aDecoder.decodeObject(forKey: "message") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if revisionNumber != nil{
			aCoder.encode(revisionNumber, forKey: "_revision_number")
		}
		if author != nil{
			aCoder.encode(author, forKey: "author")
		}
		if date != nil{
			aCoder.encode(date, forKey: "date")
		}
		if id != nil{
			aCoder.encode(id, forKey: "id")
		}
		if message != nil{
			aCoder.encode(message, forKey: "message")
		}

	}

}