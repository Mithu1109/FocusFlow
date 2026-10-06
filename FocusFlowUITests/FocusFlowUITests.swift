//
//  FocusFlowUITests.swift
//  FocusFlowUITests
//
//  FocusFlow UI Navigation & Tab Interaction Tests
//

import XCTest

final class FocusFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testNavigationAcrossThreeMainTabs() throws {
        let app = XCUIApplication()
        app.launch()

        // 1. Verify Dashboard Tab is active on launch
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: 5), "Dashboard tab button should exist")

        // 2. Navigate to Focus Timer Tab
        let focusTimerTab = app.tabBars.buttons["Focus Timer"]
        XCTAssertTrue(focusTimerTab.exists, "Focus Timer tab button should exist")
        focusTimerTab.tap()

        // 3. Navigate to Insights Tab
        let insightsTab = app.tabBars.buttons["Insights"]
        XCTAssertTrue(insightsTab.exists, "Insights tab button should exist")
        insightsTab.tap()

        // 4. Return to Dashboard Tab
        dashboardTab.tap()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
