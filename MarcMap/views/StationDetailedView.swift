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
    @StateObject var masterViewModel: MasterViewModel
    
    // @State var trains = [Train]()
    // @State var details = [tripUpdate]()
    @State var activeTrain = false
    @State var showAllTrains = false
    @State var noTrainsToday = false
    
    @State var trainsGoingToStation: [CombinedTrainObject] = []
    
    @State var directionInput: directionChocies = .outbound
    @State var dateInput: Date = .init()
    @State var lineInput: lineChoice = .Camden
    
    @State var timetableTrains: [timetableResponse] = []
    
    let stations = loadStations()
    
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
            formattedDayOfWeek = 6 // 6 = sunday, 0 = monday
        } else if dayOfWeek == 2 {
            formattedDayOfWeek = 0
        } else if dayOfWeek == 3 {
            formattedDayOfWeek = 1 // 5 = saturday
        } else if dayOfWeek == 4 {
            formattedDayOfWeek = 2 // 5 = saturday
        } else if dayOfWeek == 5 {
            formattedDayOfWeek = 3 // 5 = saturday
        } else if dayOfWeek == 6 {
            formattedDayOfWeek = 4
        } else {
            formattedDayOfWeek = 5
        }
        print("HELLO: \(formattedDayOfWeek)")
        
        apiCall().getTimetable(lineName: lineInput.rawValue, day_of_week: formattedDayOfWeek, direction: directionInput.rawValue, stop_id: formatted_stop_id) { tt in
            timetableTrains = tt ?? []
            print(timetableTrains)
            timetableTrains.sort { tt1, tt2 in
                let inputFormat = DateFormatter()
                inputFormat.dateFormat = "HH:mm:ss"
                
                guard let date1 = inputFormat.date(from: tt1.arrival_time), let date2 = inputFormat.date(from: tt2.arrival_time) else {
                    return true
                }
                
                return date1.timeIntervalSince1970 < date2.timeIntervalSince1970
            }
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
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.top, 0).background(CustomColors.MarcOrange).onAppear { // added paddingTop 40 for duo
                    if stationObj.defaultLine[0].lowercased() == "penn" {
                        lineInput = .Penn
                    }
                    if stationObj.defaultLine[0].lowercased() == "brunswick" {
                        lineInput = .Brunswick
                    }
                    if stationObj.defaultLine[0].lowercased() == "camden" {
                        lineInput = .Camden
                    }
                    if stationObj.defaultLine[0].lowercased() == "brunswick" || stationObj.defaultLine[0].lowercased() == "camden" {
                        let dayOfWeek: Int = Calendar.current.dateComponents([.weekday], from: dateInput).weekday ?? 7 // 1 - 7, with 1 being Sunday and 7 being Saturday
                        if dayOfWeek == 1 {
                            noTrainsToday = true
                            dateInput = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? dateInput
                        }
                        if dayOfWeek == 7 {
                            noTrainsToday = true
                            dateInput = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? dateInput
                        }
                    }
                    updateTimetable()
                }
                
                //  Text("Last Updated: " + FormatTime(timestamp: trains[0].vehicle.timestamp))
                NavigationLink(destination: FullScreenMap(stations: stations, masterViewModel: masterViewModel, suppliedLoc: CLLocationCoordinate2D(
                    latitude: self.stationObj.stop_lat, longitude: self.stationObj.stop_lon
                ), suppliedSpan: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))) {
                    EmbeddedMap(locationViewModel: LocationViewModel(supplied_loc: CLLocationCoordinate2D(latitude: self.stationObj.stop_lat, longitude: self.stationObj.stop_lon)), masterViewModel: masterViewModel, tripId: "", suppliedSpan: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)).frame(width: geometry.size.width * 0.90, height: 200).cornerRadius(15).padding(.bottom, 0).allowsHitTesting(false)
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
                    List(trainsGoingToStation) { combined in
                        VStack(alignment: .leading) {
                            NavigationLink(destination: TrainDetailedView(masterViewModel: masterViewModel, data: combined)) {
                                TrainListItem(masterViewModel: masterViewModel, train: combined, stopsAway: GetTrainsUpcomingStations(data: combined, stations: stations).firstIndex(of: stationObj.pretty_stop_name), favorited: false)
                                
                            }.navigationLinkIndicatorVisibility(.hidden)
                            
                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        
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
                    if noTrainsToday {
                        Text("No trains today. Showing next weekday.")
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
        }.onReceive(masterViewModel.$data, perform: { trains in // update markers
            trainsGoingToStation = GetTrainsGoingToStation(pretty_stop_name: stationObj.pretty_stop_name, data: trains, stations: masterViewModel.stations)
        })
    }
}
