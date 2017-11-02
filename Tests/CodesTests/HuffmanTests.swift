//
//  HuffmanTests.swift
//  CodesTests
//
//  Created by Paul Kraft on 01.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

// swiftlint:disable trailing_whitespace

extension String {
    init(unterminated: [UInt8]) {
        self.init(cString: unterminated + [0])
    }
}

class HuffmanTests: XCTestCase {
    
    func test() {}
    static var loremIpsum = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit.
        Quisque a metus vel quam interdum aliquet.
        Aenean lobortis, arcu non hendrerit gravida, nibh urna lobortis tortor, id maximus dui ipsum a neque.
        Duis a facilisis sem, vel rutrum ligula. Nunc ornare fringilla est non iaculis.
        Proin suscipit, justo vel accumsan scelerisque, risus sapien iaculis orci, sit amet maximus odio magna ut orci.
        In dui nulla, egestas at molestie a, interdum ut sem.
        Proin turpis justo, rutrum at accumsan ut, tincidunt vitae orci.
        Nulla fermentum elit ut fringilla faucibus.
        Donec scelerisque mauris id augue tincidunt, ac iaculis diam aliquam.
        Curabitur ornare sem id erat vehicula feugiat.
        Vestibulum varius felis sit amet odio vehicula, quis congue elit eleifend.
        Nullam eu nunc in lacus laoreet tincidunt. Aliquam in neque elementum, vulputate libero at, pharetra odio.
        Aliquam quis consequat tellus, a tristique purus. Integer dictum quis ipsum a egestas.
        Praesent ex urna, euismod id orci non, mollis egestas sapien.
        Cras in massa at massa auctor faucibus. Nam vulputate erat a lorem accumsan, vel dapibus sem lobortis.
        Phasellus at arcu fermentum, vehicula massa vel, interdum dui.
        Nunc et porta libero. Aenean sollicitudin est id iaculis fringilla.
        """
    
    /*
    func testStrings() {
        test(string: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBCCCCCCDDDDDDEEEEEEFGHI")
        test(string: "baaaaaaaaaaaaaaaaaab")
        test(string: "abcdeebcda")
        test(string: "dsklajdaoicjpoibduisfahildaölkhjvscnxeiuwgjkhsfkjldkabcjkbrjkahkjsdhkjsnc")
        test(string: "kjdsnacnueiqwrz3 uieuz iweurzwq djsashd kjhfadkjf iufeweuhjkbgadkjhgdskhgds")
        test(string: ("r" * 300) + ("a" * 20) + ("c" * 50))
        test(string: HuffmanTests.loremIpsum)
    }
    
    func test(string: String) {
        let start = Date()
        let bytes = [UInt8](string.utf8)
        let huffmanProb = Huffman(optimizedFor: bytes)!
        let huffmanCode = Huffman(codes: huffmanProb.codes)!
        
        print("generated codes:", huffmanProb.codes.map { "\(UnicodeScalar($0.key)):\($0.value)" })
        
        print("init done after", -start.timeIntervalSinceNow)
        
        let encodedProb = try! huffmanProb.encode(bytes)
        let encodedCode = try! huffmanCode.encode(bytes)
        
        print("encoded after", -start.timeIntervalSinceNow)
        
        XCTAssertEqual(encodedCode.data, encodedProb.data)
        
        let decodedProbCode = try! huffmanCode.decode(encodedProb)
        XCTAssertEqual(String(unterminated: bytes), String(unterminated: decodedProbCode))
        
        let decodedProbProb = try! huffmanProb.decode(encodedProb)
        XCTAssertEqual(String(unterminated: bytes), String(unterminated: decodedProbProb))
        
        let decodedCodeProb = try! huffmanCode.decode(encodedCode)
        XCTAssertEqual(String(unterminated: bytes), String(unterminated: decodedCodeProb))
        
        let decodedCodeCode = try! huffmanProb.decode(encodedCode)
        XCTAssertEqual(String(unterminated: bytes), String(unterminated: decodedCodeCode))
        
        print("decoded after", -start.timeIntervalSinceNow)
        
        let codes = String(huffmanProb.codes
             .map({ "\(UnicodeScalar($0.key)):\($0.value)" }).description.characters
             .filter { $0 != "\"" && $0 != " " })
        
        // print(codes)
        let encSize = encodedProb.data.count
        let origSize = bytes.count
        
        let encodingData = codes.utf8.count
        
        let percentageWithoutCodes = Int(Double(encSize) / Double(origSize) * 100)
        let percentageWithCodes = Int(Double(encSize + encodingData) / Double(origSize) * 100)
        // XCTAssert(percentage < 100)
        
        print("Encoding resulted in", encSize, "bytes which is", percentageWithoutCodes, "% without the codes",
             "and", percentageWithCodes, "% with the codes of the original size.")
    }
     */
}
