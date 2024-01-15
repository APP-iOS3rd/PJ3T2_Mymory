//
//  MapViewModelTest.swift
//  MyMemoryTests
//
//  Created by 김태훈 on 1/8/24.
//

import XCTest
@testable import MyMemory

final class MapViewModelTest: XCTestCase {
    var viewModel: MainMapViewModel!
    override func setUpWithError() throws {
        viewModel = MainMapViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }
    func testSwitchUserLocation() {
        // 초기값 확인
        XCTAssert(viewModel.isUserTracking == true)
        
        // switchUserLocation 호출 후 값 확인
        viewModel.switchUserLocation()
        XCTAssert(viewModel.isUserTracking == true)
    }
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
