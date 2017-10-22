//
//  XMLElement.swift
//  SingMusic
//
//  Created by Ben Spratling on 1/9/17.
//  Copyright © 2017 benspratling.com. All rights reserved.
//

import Foundation

public protocol XMLChild {
}


public class XMLElement {
	
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
	
	public func child(named childName:String)->XMLElement? {
		for aChild in children {
			guard let childNode = aChild as? XMLElement else { continue }
			if childNode.name == childName {
				return childNode
			}
		}
		return nil
	}
	
	
	public func children(named childName:String, range:CountableRange<Int>? = nil)->([XMLElement], Set<Int>) {
		let searchRange:CountableRange<Int> = range ?? 0..<children.count
		var indexes = Set<Int>()
		var foundChildren:[XMLElement] = []
		for (index, child) in children[searchRange].enumerated() {
			guard let nodeChild = child as? XMLElement else { continue }
			if nodeChild.name != childName { continue }
			indexes.insert(index)
			foundChildren.append(nodeChild)
		}
		return (foundChildren, indexes)
	}
	
	public func removeStringOnlyChildren() {
		children = children.filter({ (child) -> Bool in
			return child is XMLElement
		})
	}
	
}


extension String : XMLChild {
}

extension XMLElement : XMLChild {
}


public class DataToXMLElementFactory : NSObject, XMLParserDelegate {
	let xmlParser:XMLParser
	var nodeStack:[XMLElement]
	var completion:((_ node:XMLElement?, _ error:NSError?)->())?
	public init(data:Data) {
		nodeStack = [XMLElement()]
		nodeStack.first?.name = "Document"
		xmlParser = XMLParser(data: data)
		super.init()
		xmlParser.delegate = self
	}
	
	public func parseNode(_ completion:@escaping (_ node:XMLElement?, _ error:NSError?)->()) {
		self.completion = completion
		xmlParser.parse()
	}
	
	public func parserDidEndDocument(_ parser:XMLParser) {
		completion?(nodeStack.first, nil)
		completion = nil
	}
	
	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		let newNode:XMLElement = XMLElement()
		newNode.name = elementName
		newNode.attributes = attributeDict
		nodeStack.last?.children.append(newNode)
		nodeStack.append(newNode)
	}
	
	public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		nodeStack.removeLast()
	}
	
	public func parser(_ parser: XMLParser, foundCharacters string: String) {
		let topNode:XMLElement = nodeStack.last!
		if let lastChild = topNode.children.last as? String {
			let newString = lastChild + string
			topNode.children[topNode.children.count - 1] = newString
		} else {
			topNode.children.append(string)
		}
	}
	
	public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		completion?(nil, parseError as NSError?)
		completion = nil
	}
	
	///Accessing this the first time causes a parse operation
	public lazy var documentElement:XMLElement? = self.parseNodes()
	
	func parseNodes()->XMLElement? {
		xmlParser.parse()
		return nodeStack.first
	}
	
}


public protocol ExpressibleAsXMLElement {
	init(xmlElement:XMLElement)throws
}


public enum XMLParsingError : Error {
	case missingRequiredElement(String)
	case missingRequiredAttribute(String)
	case outOfRangeValue
	case invalidValue
	case other
}


