//
//  Created by Smirnov Maxim on 29/11/2018.
//  Copyright © 2018 Smirnov Maxim. All rights reserved.
//

import XCTest

class SwiftInitializerGeneratorTests: XCTestCase {

    func assert(input: [String], output: [String], file: StaticString = #file, line: UInt = #line) {
        do {
            let lines = try generate(selection: input, indentation: "    ", leadingIndent: "")
            if(lines != output) {
                XCTFail("Output is not correct; expected:\n\(output.joined(separator: "\n"))\n\ngot:\n\(lines.joined(separator: "\n"))",
                    file: file,
                    line: line)
            }
        } catch {
            XCTFail("Could not generate initializer: \(error)", file: file, line: line)
        }
    }

    func testNoAccessModifiers() {
        assert(
            input: [
                "let a: Int",
                "let b: Int"
            ],
            output: [
                "public init(a: Int, b: Int) {",
                "    self.a = a",
                "    self.b = b",
                "}"
            ])
    }

    func testNoProperties() {
        assert(
            input: [
                "",
                ""
            ],
            output: [
                "public init() { }"
            ])
    }

    func testEmptyLineInBetween() {
        assert(
            input: [
                "let a: Int",
                "",
                "let b: Int"
            ],
            output: [
                "public init(a: Int, b: Int) {",
                "    self.a = a",
                "    self.b = b",
                "}"
            ])
    }

    func testSingleAccessModifier() {
        assert(
            input: [
                "internal let a: Int",
                "private let b: Int"
            ],
            output: [
                "public init(a: Int, b: Int) {",
                "    self.a = a",
                "    self.b = b",
                "}"
            ])
    }

    func testDoubleAccessModifier() {
        assert(
            input: [
                "public internal(set) let a: Int",
                "public private(set) let b: Int"
            ],
            output: [
                "public init(a: Int, b: Int) {",
                "    self.a = a",
                "    self.b = b",
                "}"
            ])
    }


    func testCommentLine() {
        assert(
            input: [
                "/// a very important property",
                "let a: Int",
                "// this one, not so much",
                "let b: Int",
                "/*",
                " * pay attention to this one",
                " */",
                "let c: IBOutlet!"
            ],
            output: [
                "public init(a: Int, b: Int, c: IBOutlet!) {",
                "    self.a = a",
                "    self.b = b",
                "    self.c = c",
                "}"
            ])
    }

    func testDynamicVar() {
        assert(
            input: ["dynamic var hello: String",
                    "dynamic var a: Int?",
                    "var b: Float"],
            output: [
                "public init(hello: String, a: Int?, b: Float) {",
                "    self.hello = hello",
                "    self.a = a",
                "    self.b = b",
                "}"
            ])
    }

    func testEscapingClosure() {
        assert(
            input: [
                "let a: (String) -> Int?",
                "let b: () -> () -> Void",
                "let c: ((String, Int))->()",
                ],
            output: [
                "public init(a: @escaping (String) -> Int?,",
                "            b: @escaping () -> () -> Void,",
                "            c: @escaping ((String, Int))->()) {",
                "    self.a = a",
                "    self.b = b",
                "    self.c = c",
                "}"
            ])
    }

    func testNoEscapingAttribute() {
        assert(
            input: [
                "let a: (() -> Void)?",
                "let b: [() -> Void]",
                "let c: (()->())!"
            ],
            output: [
                "public init(a: (() -> Void)?, b: [() -> Void], c: (()->())!) {",
                "    self.a = a",
                "    self.b = b",
                "    self.c = c",
                "}"
            ])
    }

    func testUnderscoredWillRemoveFromInitMethod() {
        assert(
            input: [
                "private let _a: Int",
                "let b: Int"
            ],
            output: [
                "public init(a: Int, b: Int) {",
                "    _a = a",
                "    self.b = b",
                "}"
            ])
    }

    func testForExcludingImutablesPropertiesWithDefaultValue() {
        assert(
            input: [
                "let a: Int = 5"
            ],
            output: [
                "public init() { }"
            ])
    }

    func testForExcludingImutablesPropertiesWithDefaultValueAndKeepsOthers() {
        assert(
            input: [
                "let a: Int = 5",
                "let b: Int",
                "var c: Int"
            ],
            output: [
                "public init(b: Int, c: Int) {",
                "    self.b = b",
                "    self.c = c",
                "}"
            ])
    }

    func testInOneValueCase() {
        assert(
            input: [
                "let a: Int"
            ],
            output: [
                "public init(a: Int) {",
                "    self.a = a",
                "}"
            ])
    }

    func testForSkippingComputedProperties() {
        assert(
            input: [
                "var a: Int {",
                "   return 5 ",
                "}",
                "let b: Int",
                "var c: Int"
            ],
            output: [
                "public init(b: Int, c: Int) {",
                "    self.b = b",
                "    self.c = c",
                "}"
            ])
    }
}
