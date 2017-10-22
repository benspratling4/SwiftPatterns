//
//  XMLElementTests.swift
//  SwiftPatternsTests
//
//  Created by Ben Spratling on 10/22/17.
//

import XCTest

import SwiftPatterns

class XMLItemTests: XCTestCase {

	static let testXml:Data = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><ListBucketResult xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\"><Name>sprat-test-0002</Name><Prefix></Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><Delimiter></Delimiter><IsTruncated>false</IsTruncated><Contents><Key>testforibmcloudupload.json</Key><LastModified>2017-10-22T03:10:10.084Z</LastModified><ETag>\"6a6b513f6af7dee26244676936fdb9ca\"</ETag><Size>14</Size><Owner><ID>4ff2151921174fcd8efddfe4a0cc18d4</ID><DisplayName>4ff2151921174fcd8efddfe4a0cc18d4</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>".data(using: .utf8)!
	
	func testParse() {
		guard let document = DataToXMLItemFactory(data: XMLItemTests.testXml).documentItem else {
			XCTFail()
			return
		}
		guard let firstChild = document.children.first as? XMLItem
			,firstChild.name == "ListBucketResult"
			else {
			XCTFail()
			return
		}
		print(document)
		
		
		
		
	}
	
	
	static var allTests = [
		("testParse",testParse),
	]
	
}
