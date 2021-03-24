//
//	Author.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class Author : NSObject, NSCoding, Mappable{

	var accountId : Int?
	var avatars : [Avatar]?
	var email : String?
	var name : String?
	var username : String?
    var displayName: String?
    var registeredOn: String?


	class func newInstance(map: Map) -> Mappable?{
		return Author()
	}
	required init?(map: Map){}
	private override init(){}

    func mapping(map: Map)
    {
        accountId <- map["_account_id"]
        avatars <- map["avatars"]
        email <- map["email"]
        name <- map["name"]
        username <- map["username"]
        displayName <- map["display_name"]
        registeredOn <- map["registered_on"]
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
        accountId = aDecoder.decodeObject(forKey: "_account_id") as? Int
        avatars = aDecoder.decodeObject(forKey: "avatars") as? [Avatar]
        email = aDecoder.decodeObject(forKey: "email") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        username = aDecoder.decodeObject(forKey: "username") as? String
        displayName = aDecoder.decodeObject(forKey: "display_name") as? String
        registeredOn = aDecoder.decodeObject(forKey: "registered_on") as? String
    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        if accountId != nil{
            aCoder.encode(accountId, forKey: "_account_id")
        }
        if avatars != nil{
            aCoder.encode(avatars, forKey: "avatars")
        }
        if email != nil{
            aCoder.encode(email, forKey: "email")
        }
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        if username != nil{
            aCoder.encode(username, forKey: "username")
        }
        if displayName != nil{
            aCoder.encode(displayName, forKey: "display_name")
        }
        if registeredOn != nil {
            aCoder.encode(displayName, forKey: "registered_on")
        }
    }

}
