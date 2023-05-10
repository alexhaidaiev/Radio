//
//  FindWayViewModel.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 23.03.2023.
//

import Foundation

class FindWayViewModel: ObservableObject {
    private typealias LoadableGraph = Loadable<Graph, ConnectionsDataProviderError>
    
    enum Action {
        case onAppear
        case showPossibleTrips
        case loadData
        case fromCityChanged, toCityChanged
//        case debug // TODO: add various options
    }
    
    private enum Event {
        // Outside:
        case updateLoadableGraph(to: LoadableGraph)
        // Inside:
        case bestTripWillUpdate(_ new: Trip?)
    }
    
    enum R: TextResources {
        enum Text: String {
            case descriptionPlaceHolder = ""
            case descriptionDepartmentEmpty = "Please choose department city first"
            case descriptionDestinationEmpty = "Please choose destination city first"
            case descriptionDepartmentUnknown = "Unknown department city, pls choose another from the dropdown"
            case descriptionDestinationUnknown = "Unknown destination city, pls choose another from the dropdown"
            case descriptionSameCities = "Department and Destination cities must be different"
            case descriptionEmptyLoadResults = "No data"
            case descriptionEmptySearchResults = "No trips found"
            case descriptionReadyToSearch = "Ready to search"
            case descriptionBestCost = "Best cost is"
        }
    }
    
    @Published var fromCity: City
    @Published var toCity: City
    @Published private(set) var allAvailableFromCities: [City] = []
    @Published private(set) var allAvailableToCities: [City] = []
    @Published private(set) var descriptionField = R.text(.descriptionPlaceHolder)
    @Published private(set) var bestTrip: Trip?
    @Published private(set) var isLoading = false
    @Published private(set) var isShowTripAvailable = false
    
    fileprivate var currency: String { diContainer.appState[\.remoteConfig].currency.symbol }
    
    private let diContainer: DIContainer
    fileprivate let dataProvider: any ConnectionsDataProvider
    
    private var loadableGraph: LoadableGraph = .notStarted
    private var cancellable: CancellableContainer = .init()
    
    init(fromCity: City = "",
         toCity: City = "",
         diContainer: DIContainer,
         dataProvider: (any ConnectionsDataProvider)? = nil) {
        self.fromCity = fromCity
        self.toCity = toCity
        self.diContainer = diContainer
        self.dataProvider = dataProvider ?? diContainer.dataProviderFactory.createConnectionsDP()
        
        $bestTrip
            .sink { [weak self] newTrip in
                self?.handleEvent(.bestTripWillUpdate(newTrip))
            }.store(in: cancellable)
    }
    
    func handleAction(_ action: Action) {
        switch action {
        case .onAppear:
            if loadableGraph == .notStarted {
                loadData()
            }
        case .showPossibleTrips:
            let findCheapestTrip = { [weak self] graph in
                guard let self else { return }
                if self.handleAndValidateFieldsBeforeSearch(&self.fromCity, &self.toCity) {
                    self.bestTrip = Self.findCheapestTrip(from: self.fromCity,
                                                          to: self.toCity,
                                                          in: graph)
                }
            }
            if let graph = loadableGraph.data {
                findCheapestTrip(graph)
            } else {
                loadData(successAction: findCheapestTrip)
            }
        case .loadData:
            loadData()
        case .fromCityChanged, .toCityChanged:
            bestTrip = nil
            descriptionField = R.text(.descriptionPlaceHolder)
        }
    }
    
    private func handleEvent(_ event: Event) {
        switch event {
        case .updateLoadableGraph(let newGraph):
            loadableGraph = newGraph
            switch newGraph {
            case .notStarted:
                descriptionField = R.text(.descriptionPlaceHolder)
            case .isLoading:
                allAvailableToCities = []
                allAvailableFromCities = []
                descriptionField = GlobalR.text(.loading)
            case .loaded(let graph):
                allAvailableToCities = graph.availableToCities
                allAvailableFromCities = graph.availableFromCities
                descriptionField = R.text(graph.nodes.isEmpty
                                          ? .descriptionEmptyLoadResults
                                          : .descriptionReadyToSearch)
            case .failed(let connectionsError):
                descriptionField = connectionsError.description
            }
            isLoading = newGraph.isLoading
            checkIsShowTripAvailable(for: bestTrip)
            
        case .bestTripWillUpdate(let newTrip):
            if newTrip != bestTrip {
                if let newTrip {
                    if let price = newTrip.price {
                        descriptionField = "\(R.text(.descriptionBestCost)) \(price) \(currency)"
                    } else {
                        descriptionField = R.text(.descriptionEmptySearchResults)
                    }
                } else {
                    descriptionField = R.text(.descriptionPlaceHolder)
                }
                
                checkIsShowTripAvailable(for: newTrip)
            }
        }
    }
    
    // MARK: - Private
    
    private func loadData(successAction: ((Graph) -> Void)? = nil) {
        bestTrip = nil
        
        let cancellable = CancellableContainer()
        handleEvent(.updateLoadableGraph(to: .isLoading(loadableGraph.data, cancellable)))
        
        dataProvider
            .getConnections()
            .sinkWithLoadable { [weak self] loadable in
                self?.handleEvent(.updateLoadableGraph(to: loadable))
                if let graph = loadable.data {
                    successAction?(graph)
                }
            }
            .store(in: cancellable)
    }

    private func checkIsShowTripAvailable(for trip: Trip?) {
        let new = !isLoading && trip != nil
        if isShowTripAvailable != new {
            isShowTripAvailable = new
        }
    }
    
    /// It validates fields, updates them to match capitalisation (if necessary), and  updates `descriptionField` before searching
    /// - Returns: `true` if all fields are valid
    private func handleAndValidateFieldsBeforeSearch(_ fromCity: inout City,
                                                     _ toCity: inout City) -> Bool {
        guard !fromCity.isEmpty else {
            descriptionField = R.text(.descriptionDepartmentEmpty)
            return false
        }
        guard !toCity.isEmpty else {
            descriptionField = R.text(.descriptionDestinationEmpty)
            return false
        }
        guard let indexFrom = allAvailableFromCities.firstIndex(where: {
            $0.lowercased() == fromCity.lowercased()
        }) else {
            descriptionField = R.text(.descriptionDepartmentUnknown)
            return false
        }
        
        guard let indexTo = allAvailableToCities.firstIndex(where: {
            $0.lowercased() == toCity.lowercased()
        }) else {
            descriptionField = R.text(.descriptionDestinationUnknown)
            return false
        }
        
        guard allAvailableFromCities[indexFrom] != allAvailableToCities[indexTo] else {
            descriptionField = R.text(.descriptionSameCities)
            return false
        }
        
        // Handle possible capitalisation differences
        if fromCity != allAvailableFromCities[indexFrom] {
            fromCity = allAvailableFromCities[indexFrom]
        }
        if toCity != allAvailableToCities[indexTo] {
            toCity = allAvailableToCities[indexTo]
        }
        
        return true
    }
}

extension FindWayViewModel {
    static fileprivate func findCheapestTrip(from fromCity: City,
                                             to toCity: City,
                                             in graph: Graph) -> Trip? {
        guard fromCity != toCity,
              let startNode = graph.getNode(for: fromCity),
              let endNode = graph.getNode(for: toCity) else {
            return nil
        }
        
        var unsettledNodes = Set(graph.nodes)
        var shortestDistances = [startNode: 0.0]
        var previousNodes: [Node: Node] = [:]
        
        while !unsettledNodes.isEmpty {
            guard let currentNode = unsettledNodes.min(by: {
                shortestDistances[$0, default: .infinity] < shortestDistances[$1, default: .infinity]
            }) else {
                break
            }
            
            unsettledNodes.remove(currentNode)
            
            for edge in currentNode.connections {
                let distance = edge.distance
                let neighborNode = edge.destination
                let tentativeDistance = shortestDistances[currentNode, default: .infinity] + distance
                
                if tentativeDistance < shortestDistances[neighborNode, default: .infinity] {
                    shortestDistances[neighborNode] = tentativeDistance
                    previousNodes[neighborNode] = currentNode
                }
            }
        }
        
        if shortestDistances[endNode] == nil {
            return Trip(fromCity: fromCity,
                        toCity: toCity,
                        fromCoordinates: startNode.cityCoordinates,
                        toCoordinates: endNode.cityCoordinates,
                        price: nil)
        }
        
        var currentNode = endNode
        var path = [toCity]
        
        while let previousNode = previousNodes[currentNode], previousNode != startNode {
            path.append(previousNode.city)
            currentNode = previousNode
        }
        
        path.append(fromCity)
        path.reverse()
        
        return Trip(fromCity: fromCity,
                    toCity: toCity,
                    fromCoordinates: startNode.cityCoordinates,
                    toCoordinates: endNode.cityCoordinates,
                    price: shortestDistances[endNode]!)
    }
}

// MARK: Testing

protocol FindWayViewModelPrivateTesting where Self: FindWayViewModel { }
extension FindWayViewModelPrivateTesting {
    static func privateFindCheapestTrip(from fromCity: City, to toCity: City, in graph: Graph) -> Trip? {
        return Self.findCheapestTrip(from: fromCity, to: toCity, in: graph)
    }
    
    var privateCurrency: String { currency }
}
