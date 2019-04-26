//
//	Change.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class Change : NSObject, NSCoding, Mappable{

	var number : Int?
	var branch : String?
	var changeId : String?
	var created : String?
	var deletions : Int?
	var hashtags : [AnyObject]?
	var id : String?
	var insertions : Int?
	var mergeable : Bool?
	var messages : [Message]?
	var owner : Author?
	var project : String?
	var status : String?
	var subject : String?
	var submittable : Bool?
	var updated : String?


	class func newInstance(map: Map) -> Mappable?{
		return Change()
	}
	required init?(map: Map){}
	private override init(){}

	func mapping(map: Map)
	{
		number <- map["_number"]
		branch <- map["branch"]
		changeId <- map["change_id"]
		created <- map["created"]
		deletions <- map["deletions"]
		hashtags <- map["hashtags"]
		id <- map["id"]
		insertions <- map["insertions"]
		mergeable <- map["mergeable"]
		messages <- map["messages"]
		owner <- map["owner"]
		project <- map["project"]
		status <- map["status"]
		subject <- map["subject"]
		submittable <- map["submittable"]
		updated <- map["updated"]
		
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         number = aDecoder.decodeObject(forKey: "_number") as? Int
         branch = aDecoder.decodeObject(forKey: "branch") as? String
         changeId = aDecoder.decodeObject(forKey: "change_id") as? String
         created = aDecoder.decodeObject(forKey: "created") as? String
         deletions = aDecoder.decodeObject(forKey: "deletions") as? Int
         hashtags = aDecoder.decodeObject(forKey: "hashtags") as? [AnyObject]
         id = aDecoder.decodeObject(forKey: "id") as? String
         insertions = aDecoder.decodeObject(forKey: "insertions") as? Int
         mergeable = aDecoder.decodeObject(forKey: "mergeable") as? Bool
         messages = aDecoder.decodeObject(forKey: "messages") as? [Message]
         owner = aDecoder.decodeObject(forKey: "owner") as? Author
         project = aDecoder.decodeObject(forKey: "project") as? String
         status = aDecoder.decodeObject(forKey: "status") as? String
         subject = aDecoder.decodeObject(forKey: "subject") as? String
         submittable = aDecoder.decodeObject(forKey: "submittable") as? Bool
         updated = aDecoder.decodeObject(forKey: "updated") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if number != nil{
			aCoder.encode(number, forKey: "_number")
		}
		if branch != nil{
			aCoder.encode(branch, forKey: "branch")
		}
		if changeId != nil{
			aCoder.encode(changeId, forKey: "change_id")
		}
		if created != nil{
			aCoder.encode(created, forKey: "created")
		}
		if deletions != nil{
			aCoder.encode(deletions, forKey: "deletions")
		}
		if hashtags != nil{
			aCoder.encode(hashtags, forKey: "hashtags")
		}
		if id != nil{
			aCoder.encode(id, forKey: "id")
		}
		if insertions != nil{
			aCoder.encode(insertions, forKey: "insertions")
		}
		if mergeable != nil{
			aCoder.encode(mergeable, forKey: "mergeable")
		}
		if messages != nil{
			aCoder.encode(messages, forKey: "messages")
		}
		if owner != nil{
			aCoder.encode(owner, forKey: "owner")
		}
		if project != nil{
			aCoder.encode(project, forKey: "project")
		}
		if status != nil{
			aCoder.encode(status, forKey: "status")
		}
		if subject != nil{
			aCoder.encode(subject, forKey: "subject")
		}
		if submittable != nil{
			aCoder.encode(submittable, forKey: "submittable")
		}
		if updated != nil{
			aCoder.encode(updated, forKey: "updated")
		}

	}

}