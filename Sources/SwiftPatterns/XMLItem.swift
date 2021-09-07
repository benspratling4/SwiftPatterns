//
//  XMLItem.swift
//  SingMusic
//
//  Created by Ben Spratling on 1/9/17.
//  Copyright © 2017 benspratling.com. All rights reserved.
//

import Foundation

public protocol XMLChild {
}


public class XMLItem {
	
	public var name:String?
	
	public var attributes:[String:String] = [:]
	
	public var children:[XMLChild] = []
	
	public init(name:String? = nil, attributes:[String:String] = [:], children:[XMLChild] = []) {
		self.name = name
		self.attributes = attributes
		self.children = children
	}
	
	/// Collect all child strings
	public var childString:String {
		var collectedString = ""
		for aChild in children {
			if let childString = aChild as? String {
				collectedString += childString
			}
		}
		return collectedString
	}
	
	public var childInt:Int? {
		return Int(childString)
	}
	
	public func child(named childName:String)->XMLItem? {
		for aChild in children {
			guard let childNode = aChild as? XMLItem else { continue }
			if childNode.name == childName {
				return childNode
			}
		}
		return nil
	}
	
	
	public func children(named childName:String, range:CountableRange<Int>? = nil)->([XMLItem], Set<Int>) {
		let searchRange:CountableRange<Int> = range ?? 0..<children.count
		var indexes = Set<Int>()
		var foundChildren:[XMLItem] = []
		for (index, child) in children[searchRange].enumerated() {
			guard let nodeChild = child as? XMLItem else { continue }
			if nodeChild.name != childName { continue }
			indexes.insert(index)
			foundChildren.append(nodeChild)
		}
		return (foundChildren, indexes)
	}
	
	public func removeStringOnlyChildren() {
		children = children.filter({ (child) -> Bool in
			return child is XMLItem
		})
	}
	
}


extension String : XMLChild {
}

extension XMLItem : XMLChild {
}


public class DataToXMLItemFactory : NSObject, XMLParserDelegate {
	let xmlParser:XMLParser
	var nodeStack:[XMLItem]
	var completion:((_ node:XMLItem?, _ error:Error?)->())?
	public init(data:Data) {
		nodeStack = [XMLItem()]
		nodeStack.first?.name = "Document"
		xmlParser = XMLParser(data: data)
		super.init()
		xmlParser.delegate = self
	}
	
	public func parseNode(_ completion:@escaping (_ node:XMLItem?, _ error:Error?)->()) {
		self.completion = completion
		xmlParser.parse()
	}
	
	public func parserDidEndDocument(_ parser:XMLParser) {
		completion?(nodeStack.first, nil)
		completion = nil
	}
	
	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		let newNode:XMLItem = XMLItem()
		newNode.name = elementName
		newNode.attributes = attributeDict
		nodeStack.last?.children.append(newNode)
		nodeStack.append(newNode)
	}
	
	public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		nodeStack.removeLast()
	}
	
	public func parser(_ parser: XMLParser, foundCharacters string: String) {
		let topNode:XMLItem = nodeStack.last!
		if let lastChild = topNode.children.last as? String {
			let newString = lastChild + string
			topNode.children[topNode.children.count - 1] = newString
		} else {
			topNode.children.append(string)
		}
	}
	
	public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		completion?(nil, parseError)
		completion = nil
	}
	
	@available(*, unavailable, renamed: "documentItem")
	public var documentElement:XMLItem? {
		return documentItem
	}
	
	///Accessing this the first time causes a parse operation
	public lazy var documentItem:XMLItem? = self.parseNodes()
	
	func parseNodes()->XMLItem? {
		xmlParser.parse()
		return nodeStack.first
	}
	
}


public protocol ExpressibleAsXMLItem {
	init(XMLItem:XMLItem)throws
}

@available(*, unavailable, renamed: "ExpressibleAsXMLItem")
public typealias ExpressibleAsXMLElement = ExpressibleAsXMLItem


public enum XMLParsingError : Error {
	case missingRequiredElement(String)
	case missingRequiredAttribute(String)
	case outOfRangeValue
	case invalidValue
	case other
}


