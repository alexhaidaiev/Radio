////
////  FindWayViewModelTests.swift
////  FindWayTests
////
////  Created by Oleksandr Haidaiev on 26.03.2023.
////
//
import XCTest
import Combine
@testable import FindWay

class FindWayViewModelTests: XCTestCase {
    private typealias SUT = FindWayViewModel
    
    var di: DIContainer!
    let cancellable = CancellableContainer()
    
    override func setUp() {
        super.setUp()
        di = DIContainer.mockedTests
    }
    
    override func tearDown() {
        di = nil
        super.tearDown()
    }
    
    // MARK: - Traditional tests
    
    func testScreenLaunchSuccessLoading() {
        let fakeDataProvider = FakeConnectionsDataProvider()
        let sut = FindWayViewModel(diContainer: di, dataProvider: fakeDataProvider)
        let expectation = expectation(description: #function)
        
        XCTAssertTrue(!sut.isLoading)
        XCTAssertTrue(!sut.isShowTripAvailable)
        XCTAssertTrue(sut.allAvailableFromCities.isEmpty)
        XCTAssertTrue(sut.allAvailableToCities.isEmpty)
        XCTAssertEqual(sut.descriptionField, SUT.R.text(.descriptionPlaceHolder))
        
        sut.handleAction(.onAppear)
        
        XCTAssertTrue(sut.isLoading)
        XCTAssertEqual(sut.descriptionField, GlobalR.text(.loading))
        fakeDataProvider.getConnectionsFinished = {
            XCTAssertTrue(!sut.isLoading)
            XCTAssertTrue(!sut.isShowTripAvailable)
            XCTAssertTrue(!sut.allAvailableFromCities.isEmpty)
            XCTAssertTrue(!sut.allAvailableToCities.isEmpty)
            XCTAssertEqual(sut.descriptionField, SUT.R.text(.descriptionReadyToSearch))
            expectation.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testScreenLaunchFailLoading() {
        let apiError: APIError = .forTesting
        let fakeDataProvider = FakeConnectionsDataProvider(apiErrorToFailWith: apiError)
        let sut = FindWayViewModel(diContainer: di, dataProvider: fakeDataProvider)
        let expectation = expectation(description: #function)
        
        XCTAssertTrue(!sut.isLoading)
        XCTAssertTrue(!sut.isShowTripAvailable)
        XCTAssertTrue(sut.allAvailableFromCities.isEmpty)
        XCTAssertTrue(sut.allAvailableToCities.isEmpty)
        XCTAssertEqual(sut.descriptionField, SUT.R.text(.descriptionPlaceHolder))
        
        sut.handleAction(.onAppear)
        
        XCTAssertTrue(sut.isLoading)
        XCTAssertEqual(sut.descriptionField, GlobalR.text(.loading))
        fakeDataProvider.getConnectionsFinished = {
            XCTAssertTrue(!sut.isLoading)
            XCTAssertTrue(!sut.isShowTripAvailable)
            XCTAssertTrue(sut.allAvailableFromCities.isEmpty)
            XCTAssertTrue(sut.allAvailableToCities.isEmpty)
            XCTAssertTrue(sut.descriptionField.contains(apiError.description))
            expectation.fulfill()
        }
        
        waitForExpectations() // standard testing of async code
    }
    
    func testEmptyLoadResults() {
        executeAsyncWorkWithTimeout { [self] in // a wrapper to test async code
            let fakeDataProvider = FakeConnectionsDataProvider(getConnectionsAPIValue: .fakeEmpty)
            let sut = FindWayViewModel(diContainer: di, dataProvider: fakeDataProvider)
            
            XCTAssertTrue(!sut.isLoading)
            
            sut.handleAction(.loadData)
            
            XCTAssertTrue(sut.isLoading)
            XCTAssertEqual(sut.descriptionField, GlobalR.text(.loading))
            await getConnectionsFinished(fakeDataProvider)
            XCTAssertTrue(!sut.isLoading)
            XCTAssertTrue(!sut.isShowTripAvailable)
            XCTAssertTrue(sut.allAvailableFromCities.isEmpty)
            XCTAssertTrue(sut.allAvailableToCities.isEmpty)
            XCTAssertEqual(sut.descriptionField, SUT.R.text(.descriptionEmptyLoadResults))
        }
    }
    
    func testFindTripEmptySearchResults() {
        executeAsyncWorkWithTimeout { [self] in
            let fakeDataProvider = FakeConnectionsDataProvider(jsonFileToUse: .isolated)
            let sut = FindWayViewModel(diContainer: di, dataProvider: fakeDataProvider)
            sut.handleAction(.loadData)
            await getConnectionsFinished(fakeDataProvider)
            emulateFromCityChange(to: "London", sut: sut)
            emulateToCityChange(to: "Sydney", sut: sut)
            
            XCTAssertEqual(sut.descriptionField, SUT.R.text(.descriptionPlaceHolder))
            
            sut.handleAction(.showPossibleTrips)
            
            XCTAssertEqual(sut.descriptionField, SUT.R.text(.descriptionEmptySearchResults))
        }
    }
    
    // MARK: - Tests of various scenarios
    
    func testScreenCommonScenario() {
        withTimeout(defaultTimeoutMultiplier: 2) { [self] in
            let fakeDataProvider = FakeConnectionsDataProvider()
            let sut = FindWayViewModel(diContainer: di, dataProvider: fakeDataProvider)
            
            await screenLaunchScenario(fakeDataProvider, sut: sut)
            findTripScenario(sut: sut)
            await reloadConnectionsScenario(fakeDataProvider, sut: sut)
        }
    }
    
    func testScreenCommonScenarioWithFailLoadings() {
        withTimeout(defaultTimeoutMultiplier: 2) { [self] in
            let apiError: APIError = .forTesting
            let fakeDataProvider = FakeConnectionsDataProvider(apiErrorToFailWith: apiError)
            let sut = FindWayViewModel(diContainer: di, dataProvider: fakeDataProvider)
            
            await screenLaunchScenario(fakeDataProvider, sut: sut, expectedError: apiError)
            await findTripScenarioWithEmptyData(fakeDataProvider, sut: sut, expectedError: apiError)
            fakeDataProvider.apiErrorToFailWith = nil
            await findTripScenarioWithEmptyData(fakeDataProvider, sut: sut, expectedError: nil)
            await reloadConnectionsScenario(fakeDataProvider, sut: sut)
            findTripScenario(sut: sut)
        }
    }
    
    private func screenLaunchScenario(_ fakeDataProvider: FakeConnectionsDataProvider,
                                      sut: FindWayViewModel,
                                      expectedError: APIError? = nil) async {
        XCTAssertTrue(!sut.isLoading)
        XCTAssertTrue(!sut.isShowTripAvailable)
        XCTAssertTrue(sut.fromCity.isEmpty)
        XCTAssertTrue(sut.toCity.isEmpty)
        XCTAssertTrue(sut.allAvailableFromCities.isEmpty)
        XCTAssertTrue(sut.allAvailableToCities.isEmpty)
        XCTAssertEqual(sut.descriptionField, SUT.R.text(.descriptionPlaceHolder))
        
        sut.handleAction(.onAppear)
        
        XCTAssertTrue(sut.isLoading)
        XCTAssertEqual(sut.descriptionField, GlobalR.text(.loading))
        await getConnectionsFinished(fakeDataProvider)
        XCTAssertTrue(!sut.isLoading)
        XCTAssertTrue(!sut.isShowTripAvailable)
        if let expectedError {
            XCTAssertTrue(sut.allAvailableFromCities.isEmpty)
            XCTAssertTrue(sut.allAvailableToCities.isEmpty)
            XCTAssertEqual(sut.descriptionField, expectedError.description)
        } else {
            XCTAssertTrue(!sut.allAvailableFromCities.isEmpty)
            XCTAssertTrue(!sut.allAvailableToCities.isEmpty)
            XCTAssertEqual(sut.descriptionField, SUT.R.text(.descriptionReadyToSearch))
        }
    }
    
    private func findTripScenario(sut: FindWayViewModel) {
        let showTripsWithCommonChecksForFailCase = { (expectedDescriptionText: String) -> Void in
            XCTAssertEqual(sut.descriptionField, SUT.R.text(.descriptionPlaceHolder))
            XCTAssertTrue(!sut.isShowTripAvailable)
            sut.handleAction(.showPossibleTrips)
            XCTAssertEqual(sut.descriptionField, expectedDescriptionText)
            XCTAssertTrue(!sut.isShowTripAvailable)
        }
        
        // Both are empty (start conditions)
        emulateFromCityChange(to: "", sut: sut)
        emulateToCityChange(to: "", sut: sut)
        showTripsWithCommonChecksForFailCase(SUT.R.text(.descriptionDepartmentEmpty))

        // Incorrect department, empty destination
        emulateFromCityChange(to: "asdqwe", sut: sut)
        showTripsWithCommonChecksForFailCase(SUT.R.text(.descriptionDestinationEmpty))

        // Both are incorrect
        emulateToCityChange(to: "qweasd", sut: sut)
        showTripsWithCommonChecksForFailCase(SUT.R.text(.descriptionDepartmentUnknown))
        
        // Correct department only
        emulateFromCityChange(to: "londoN", sut: sut)
        showTripsWithCommonChecksForFailCase(SUT.R.text(.descriptionDestinationUnknown))
        
        // Both are correct
        emulateToCityChange(to: "toKyo", sut: sut)
        XCTAssertEqual(sut.descriptionField, SUT.R.text(.descriptionPlaceHolder))
        XCTAssertTrue(!sut.isShowTripAvailable)
        sut.handleAction(.showPossibleTrips)
        XCTAssertTrue(sut.descriptionField.contains(SUT.R.text(.descriptionBestCost)))
        XCTAssertTrue(sut.isShowTripAvailable)
        XCTAssertEqual(sut.fromCity, "London")
        XCTAssertEqual(sut.toCity, "Tokyo")

        // Incorrect department, correct destination
        emulateFromCityChange(to: "asdqwe", sut: sut)
        showTripsWithCommonChecksForFailCase(SUT.R.text(.descriptionDepartmentUnknown))
        
        // Both are correct but same
        emulateFromCityChange(to: "Tokyo", sut: sut)
        showTripsWithCommonChecksForFailCase(SUT.R.text(.descriptionSameCities))
        
        // Both are correct
        emulateToCityChange(to: "Los Angeles", sut: sut)
        XCTAssertEqual(sut.descriptionField, SUT.R.text(.descriptionPlaceHolder))
        XCTAssertTrue(!sut.isShowTripAvailable)
        sut.handleAction(.showPossibleTrips)
        XCTAssertTrue(sut.descriptionField.contains(SUT.R.text(.descriptionBestCost)))
        XCTAssertTrue(sut.isShowTripAvailable)
    }
    
    private func findTripScenarioWithEmptyData(_ fakeDataProvider: FakeConnectionsDataProvider,
                                               sut: FindWayViewModel,
                                               expectedError: APIError? = nil) async {
        XCTAssertTrue(!sut.isLoading)
        XCTAssertTrue(sut.allAvailableFromCities.isEmpty)
        XCTAssertTrue(sut.allAvailableToCities.isEmpty)

        sut.handleAction(.showPossibleTrips)

        XCTAssertTrue(sut.isLoading)
        XCTAssertEqual(sut.descriptionField, GlobalR.text(.loading))
        await getConnectionsFinished(fakeDataProvider)
        XCTAssertTrue(!sut.isLoading)
        XCTAssertTrue(!sut.isShowTripAvailable)
        if let expectedError {
            XCTAssertTrue(sut.allAvailableFromCities.isEmpty)
            XCTAssertTrue(sut.allAvailableToCities.isEmpty)
            XCTAssertEqual(sut.descriptionField, expectedError.description)
        } else {
            XCTAssertTrue(!sut.allAvailableFromCities.isEmpty)
            XCTAssertTrue(!sut.allAvailableToCities.isEmpty)
            XCTAssertNotEqual(sut.descriptionField, SUT.R.text(.descriptionPlaceHolder))
        }
    }
    
    private func reloadConnectionsScenario(_ fakeDataProvider: FakeConnectionsDataProvider,
                                           sut: FindWayViewModel) async {
        let originalError = fakeDataProvider.apiErrorToFailWith
        
        // Fail
        let apiError: APIError = .forTesting
        fakeDataProvider.apiErrorToFailWith = apiError
        XCTAssertTrue(!sut.isLoading)
        
        sut.handleAction(.loadData)
        
        XCTAssertTrue(sut.isLoading)
        XCTAssertEqual(sut.descriptionField, GlobalR.text(.loading))
        await getConnectionsFinished(fakeDataProvider)
        XCTAssertTrue(!sut.isLoading)
        XCTAssertTrue(!sut.isShowTripAvailable)
        XCTAssertTrue(sut.allAvailableFromCities.isEmpty)
        XCTAssertTrue(sut.allAvailableToCities.isEmpty)
        XCTAssertTrue(sut.descriptionField.contains(apiError.description))
        
        // Success
        fakeDataProvider.apiErrorToFailWith = nil
        XCTAssertTrue(!sut.isLoading)
        
        sut.handleAction(.loadData)
        
        XCTAssertTrue(sut.isLoading)
        XCTAssertEqual(sut.descriptionField, GlobalR.text(.loading))
        await getConnectionsFinished(fakeDataProvider)
        XCTAssertTrue(!sut.isLoading)
        XCTAssertTrue(!sut.isShowTripAvailable)
        XCTAssertTrue(!sut.allAvailableFromCities.isEmpty)
        XCTAssertTrue(!sut.allAvailableToCities.isEmpty)
        XCTAssertEqual(sut.descriptionField, SUT.R.text(.descriptionReadyToSearch))
        
        // Restore the original state
        fakeDataProvider.apiErrorToFailWith = originalError
    }
    
    // MARK: Helpers
    
    private func emulateFromCityChange(to new: String, sut: FindWayViewModel) {
        sut.fromCity = new
        sut.handleAction(.fromCityChanged)
    }
    
    private func emulateToCityChange(to new: String, sut: FindWayViewModel) {
        sut.toCity = new
        sut.handleAction(.toCityChanged)
    }
    
    private func getConnectionsFinished(_ fakeDataProvider: FakeConnectionsDataProvider) async {
        await withCheckedContinuation { continuation in
            fakeDataProvider.getConnectionsFinished = {
                continuation.resume()
            }
        }
        fakeDataProvider.getConnectionsFinished = nil
    }
}


// MARK: - Private testing

extension FindWayViewModel: FindWayViewModelPrivateTesting { }

extension FindWayViewModelTests {
    func testFindCheapestTripFromJSON() {
        let sut = FindWayViewModel.self
        let graph: Graph = .fake(from: .londonTokyo)
        
        let result1 = sut.privateFindCheapestTrip(from: "London", to: "Tokyo", in: graph)
        let result2 = sut.privateFindCheapestTrip(from: "London2", to: "Tokyo", in: graph)
        let result3 = sut.privateFindCheapestTrip(from: "London2", to: "abc", in: graph)
        let result4 = sut.privateFindCheapestTrip(from: "asd", to: "Tokyo", in: graph)
        let result5 = sut.privateFindCheapestTrip(from: "Tokyo", to: "Tokyo", in: graph)
        
        XCTAssertNotNil(result1)
        XCTAssertEqual(result1?.fromCity, "London")
        XCTAssertEqual(result1?.toCity, "Tokyo")
        XCTAssertEqual(result1?.price, 220)
        
        XCTAssertNotNil(result2)
        XCTAssertEqual(result2?.fromCity, "London2")
        XCTAssertEqual(result2?.toCity, "Tokyo")
        XCTAssertEqual(result2?.price, 670)
        
        XCTAssertNil(result3)
        XCTAssertNil(result4)
        XCTAssertNil(result5)
    }
    
    func testFindCheapestTripFromHardcodedValues() {
        let sut = FindWayViewModel.self
        let graph1: Graph = .fakeHardCodedLondonTokyo(isDirectCostCheaper: true)
        let graph2: Graph = .fakeHardCodedLondonTokyo(isDirectCostCheaper: false)
        
        let result1 = sut.privateFindCheapestTrip(from: "London", to: "Tokyo", in: graph1)
        let result2 = sut.privateFindCheapestTrip(from: "London", to: "Tokyo", in: graph2)
        
        XCTAssertNotNil(result1)
        XCTAssertEqual(result1!.price, 375)
        
        XCTAssertNotNil(result2)
        XCTAssertEqual(result2?.price, 400)
        XCTAssertEqual(result2?.fromCity, "London")
        XCTAssertEqual(result2?.toCity, "Tokyo")
    }
    
    func testCurrency() {
        let sut = FindWayViewModel(diContainer: di)
        
        let currency = sut.privateCurrency
        
        XCTAssertEqual(currency, di.appState.currentValue.remoteConfig.currency.symbol)
    }
}
