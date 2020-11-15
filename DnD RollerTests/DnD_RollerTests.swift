//
//  DnD_RollerTests.swift
//  DnD RollerTests
//
//  Created by Peter Sichel on 11/4/20.
//

import XCTest
@testable import DnD_Roller

class DnD_RollerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDie() throws {
        let dice6 = Die(sides: 6, imageName: "dice6", imageScale: CGSize(width: 0.55, height: 0.55))
        XCTAssertEqual(dice6.sides, 6, "dice should have 6 sides")
        XCTAssertEqual(dice6.sidesStr, "", "sidesStr should be empty")
        XCTAssertEqual(dice6.imageName, "dice6", "Image name does not match")
    }

    func testDice() throws {
        let cx = ContentView()
        let myDice = cx.myDice
        // dice class should be initialized with 7 dice
        // number of sides 4, 6, 8, 10, 12, 20
        XCTAssertEqual(myDice.diceArray.count, 7, "Initialized with 7 dice")
        XCTAssertEqual(myDice.diceArray[3].sides, 10, "Die 3 should have 10 sides")
        
        // test roll 4 d4
        var die4 = myDice.diceArray[0]
        die4.howMany = 4
        myDice.calculateRoll(die: die4)
        let prefix = myDice.rollMessage.prefix(9)
        XCTAssertEqual(prefix, "Roll 4 d4", "Roll message should start Roll 4 d4")
    }

    func testDiceStats() throws {
        let cx = ContentView()
        let myDice = cx.myDice
        // 4 d4
        var die4 = myDice.diceArray[0]
        die4.howMany = 4
        // roll
        myDice.calculateRoll(die: die4)
        XCTAssertEqual(die4.diceStats.history.count, 4, "Dice Stats should have 4 entries")
        myDice.calculateRoll(die: die4)
        XCTAssertEqual(die4.diceStats.history.count, 8, "Dice Stats should have 8 entries")
        myDice.calculateRoll(die: die4)
        XCTAssertEqual(die4.diceStats.history.count, 10, "Dice Stats should truncate at 10 entries")
        die4.diceStats.addDieRoll(17)
        XCTAssertEqual(die4.diceStats.history[0], 17, "addDieRoll inserts at front of list")
        XCTAssertEqual(die4.diceStats.history.count, 10, "Still 10 entries after insert")
        // reset stats
        cx.resetDice()
        die4 = myDice.diceArray[0]
        XCTAssertEqual(die4.diceStats.history.count, 0, "Stats should reset to empty")
        // calculate average
        die4.diceStats.addDieRoll(8)
        die4.diceStats.addDieRoll(16)
        XCTAssertEqual(die4.diceStats.average, "12.0", "Average should be 12")
    }
    
    
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//            let cx = ContentView()
//            let myDice = cx.myDice
//            // 4 d4
//            var die4 = myDice.diceArray[0]
//            die4.howMany = 4
//            // roll
//            myDice.calculateRoll(die: die4)
//        }
//    }

}
