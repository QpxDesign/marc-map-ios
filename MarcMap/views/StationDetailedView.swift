//
//  StationDetailedView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import CoreLocation
import CoreLocationUI
import MapKit
import SwiftUI

enum lineChoice: String, CaseIterable, Identifiable {
    case Penn, Camden, Brunswick
    var id: Self {
        self
    }
}

enum directionChocies: String, CaseIterable, Identifiable {
    case inbound, outbound
    var id: Self {
        self
    }
}

struct StationDetailedView: View {
    var stationObj: station
    let stations: [station]
    @ObservedObject var trainsViewModel: TrainsViewModel
    @ObservedObject var tripUpdatesViewModel: TripUpdatesViewModel
    
    @State var trains = [Train]()
    @State var details = [tripUpdate]()
    @State var activeTrain = false
    @State var showAllTrains = false
    
    @State var trainsGoingToStation: [Train] = []
    
    @State var directionInput: directionChocies = .outbound
    @State var dateInput: Date = .init()
    @State var lineInput: lineChoice = .Camden
    
    @State var timetableTrains: [timetableResponse] = []
    
    let brunswick: [CLLocationCoordinate2D] = getRouteFromFile(filename: "Brunswick") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let penn: [CLLocationCoordinate2D] = getRouteFromFile(filename: "Penn") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let fred: [CLLocationCoordinate2D] = getRouteFromFile(filename: "FredrickBranch") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let camd: [CLLocationCoordinate2D] = getRouteFromFile(filename: "Camden") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    
    func updateTimetable() {
        var formatted_stop_id = "\(stationObj.stop_id)"
        formatted_stop_id.replace("[", with: "")
        formatted_stop_id.replace("]", with: "")
        formatted_stop_id.replace(" ", with: "")
        let dayOfWeek: Int = Calendar.current.dateComponents([.weekday], from: dateInput).weekday ?? 7 // 1 - 7, with 1 being Sunday and 7 being Saturday
        let formattedDayOfWeek: Int
        if dayOfWeek == 1 {
            formattedDayOfWeek = 7
        } else if dayOfWeek >= 2, dayOfWeek <= 6 {
            formattedDayOfWeek = dayOfWeek - 1
        } else {
            formattedDayOfWeek = 6
        }
         
        apiCall().getTimetable(lineName: lineInput.rawValue, day_of_week: formattedDayOfWeek, direction: directionInput.rawValue, stop_id: formatted_stop_id) { tt in
            timetableTrains = tt ?? []
        }
    }
    
    func formatDate(d: String) -> String {
        let inputFormat = DateFormatter()
        inputFormat.dateFormat = "HH:mm:ss"
        
        let outputFormat = DateFormatter()
        outputFormat.dateFormat = "h:mm a"
        
        guard let date = inputFormat.date(from: d) else {
            print("Error parsing date '\(d)'")
            return d
        }

        return outputFormat.string(from: date)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Text(stationObj.pretty_stop_name).bold().multilineTextAlignment(.leading).padding(.leading, 20).padding(.trailing, 10).padding(.bottom, 15).foregroundColor(Color.white).font(.system(size: 34))
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.top, 40).background(CustomColors.MarcOrange).onAppear { // added paddingTop 40 for duo
                    if stationObj.defaultLine[0].lowercased() == "penn" {
                        lineInput = .Penn
                    }
                    if stationObj.defaultLine[0].lowercased() == "brunswick" {
                        lineInput = .Brunswick
                    }
                    if stationObj.defaultLine[0].lowercased() == "camden" {
                        lineInput = .Camden
                    }
                }
                    
                //  Text("Last Updated: " + FormatTime(timestamp: trains[0].vehicle.timestamp))
                NavigationLink(destination: FullScreenMap(stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel, suppliedLoc: CLLocationCoordinate2D(
                    latitude: self.stationObj.stop_lat, longitude: self.stationObj.stop_lon
                ), suppliedSpan: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))) {
                    EmbeddedMap(loc: CLLocationCoordinate2D(latitude: self.stationObj.stop_lat, longitude: self.stationObj.stop_lon), tripId: "", suppliedSpan: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001), stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel).frame(width: geometry.size.width * 0.90, height: 200).cornerRadius(15).padding(.bottom, 0).allowsHitTesting(false)
                }
                    
                HStack {
                    HStack {
                        Text("Tracked Trains").fontWeight(Font.Weight.medium)
                    }.padding([.leading, .trailing], 15).padding([.vertical, .horizontal], 5).background(showAllTrains ? Color.gray : Color.orange).cornerRadius(25).onTapGesture {
                        showAllTrains = false
                    }
                    HStack {
                        Text("All Trains").fontWeight(Font.Weight.medium).foregroundColor(Color.white)
                    }.padding([.leading, .trailing], 15).padding([.vertical, .horizontal], 5).background(showAllTrains ? Color.orange : Color.gray).cornerRadius(25).onTapGesture {
                        updateTimetable()
                        showAllTrains = true
                    }
                }
                   
                if !showAllTrains {
                    List(trainsGoingToStation) { train in
                        let matching_trip_update = tripUpdatesViewModel.tripUpdates.filter { $0.trip.tripId == train.vehicle.trip.tripId }
                        if !matching_trip_update.isEmpty {
                            let stops_away = GetTrainsUpcomingStations(train: train, details: matching_trip_update[0], stations: stations).firstIndex(of: stationObj.pretty_stop_name)
                                
                            VStack(alignment: .leading) {
                                NavigationLink(destination: TrainDetailedView(tripId: train.vehicle.trip.tripId, stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel)) {
                                    TrainListItem(train: train, trip_update: matching_trip_update[0], stations: stations, stopsAway: stops_away, favorited: false)
                                        
                                }.navigationLinkIndicatorVisibility(.hidden)
                                    
                            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                    }.contentMargins(.top, 20)
                        
                } else {
                    HStack {
                        Picker("Line", selection: $lineInput) {
                            Text("Penn ").tag(lineChoice.Penn)
                            Text("Camden").tag(lineChoice.Camden)
                            Text("Brunswick").tag(lineChoice.Brunswick)
                        }.background(CustomColors.MarcBlue).accentColor(Color.white).padding([.leading, .trailing], 15).padding([.vertical, .horizontal], 5).onChange(of: lineInput) { _, _ in
                            updateTimetable()
                        }
                        Picker("Direction", selection: $directionInput) {
                            Text("Outbound").tag(directionChocies.inbound)
                            Text("Inbound").tag(directionChocies.outbound)
                        }.background(CustomColors.MarcBlue).accentColor(Color.white).padding([.leading, .trailing], 15).padding([.vertical, .horizontal], 5).onChange(of: directionInput) { _, newDirectionInput in
                            directionInput = newDirectionInput
                            updateTimetable()
                        }
                    }
                    HStack {
                        DatePicker(
                            "",
                            selection: $dateInput,
                            displayedComponents: [.date]
                        ).labelsHidden().environment(\.locale, Locale(identifier: "en")).onChange(of: dateInput) { _, _ in
                            updateTimetable()
                        }
                    }
                        
                    List(timetableTrains) { timetableTrain in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(FormatTripId(tripId: timetableTrain.trip_id))
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                    
                                Text(formatDate(d: timetableTrain.arrival_time))
                                Spacer()
                                Text(lineInput.rawValue).font(.system(size: 18))
                                    
                            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            Spacer()
                        }
                    }.contentMargins(.top, 20)
                }
            }
            Spacer()
        }.onReceive(trainsViewModel.$trains, perform: { trains in // update markers
            trainsGoingToStation = GetTrainsGoingToStation(pretty_stop_name: stationObj.pretty_stop_name, trains: trains, details: self.tripUpdatesViewModel.tripUpdates, stations: stations)
        })
    }
}
