//
//  StationDetailedView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import SwiftUI
import CoreLocation
import CoreLocationUI
import MapKit

@available(iOS 17.0, *)
struct NewStationDetailedView: View {

    var stationObj: station
    @State var trains = [Train]()
    @State var details = [tripUpdate]()
    @State var activeTrain = false
    @State var showAllTrains = false
    @State var trainsGoingToStation : [StationTrainDetails] = []
    
    @State var directionInput: directionChocies = .outbound
    @State var dateInput: Date  = Date()
    @State var lineInput: lineChoice = .Camden
    
    @State var timetableTrains: [String] = []
    @State var timetableTimes: [String] = []
    
    let brunswick : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Brunswick") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let penn : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Penn") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let fred : [CLLocationCoordinate2D] = getRouteFromFile(filename: "FredrickBranch") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let camd : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Camden") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    
    var timer1 = Timer()
    var timer2 = Timer()
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack {
                HStack {
                    Text(stationObj.stop_name).bold().multilineTextAlignment(.leading).padding(.leading,20).padding(.bottom, 15).foregroundColor(Color.white).font(.system(size: 34))
                } .frame(maxWidth: .infinity, alignment: .leading).background(CustomColors.MarcOrange).onAppear() {
                    if (stationObj.defaultLine[0].lowercased() == "penn") {
                        lineInput = .Penn
                    }
                    if (stationObj.defaultLine[0].lowercased() == "brunswick") {
                        lineInput = .Brunswick
                    }
                    if (stationObj.defaultLine[0].lowercased() == "camden") {
                        lineInput = .Camden
                    }
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    let formattedDate = dateFormatter.string(from: dateInput)
                    apiCall().getTimetable(lineName: lineInput.rawValue, date: formattedDate, direction: directionInput.rawValue) { (tt: [timetableResponse]?) in
                        if (!(tt ?? []).filter{$0.stop_name?.lowercased() ?? "" == stationObj.stop_name.lowercased()}.isEmpty && !(tt ?? []).filter{$0.stop_name?.lowercased() ?? "" == stationObj.stop_name.lowercased()}.isEmpty) {
                            self.timetableTimes = (tt ?? []).filter{$0.stop_name?.lowercased() == stationObj.stop_name.lowercased()}[0].times ?? []
                            self.timetableTrains = (tt ?? []).filter{$0.stop_name?.lowercased() == stationObj.stop_name.lowercased()}[0].trains ?? []
                        }

                        print(self.timetableTrains)
                    }
                        apiCall().getTrains { (trains) in
                            self.trains = trains ?? []
                           
                                Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer1 in
                                    if (!activeTrain) {
                                    apiCall().getTrains { (trains) in
                                        self.trains = trains ?? []
                                    }
                                }
                            }
                        }
                        apiCall().getTripUpdates{(updates) in
                            self.details = updates ?? []
                        }
                  
                        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer2 in
                            if (!activeTrain) {
                            apiCall().getTripUpdates { (updates) in
                                self.details = updates ?? []
                            }}
                    }
                    }
              
                  //  Text("Last Updated: " + FormatTime(timestamp: trains[0].vehicle.timestamp))
                    NavigationLink(destination: NewNewMapView(suppliedLoc:  CLLocationCoordinate2D(
                        latitude:self.stationObj.stop_lat, longitude:  self.stationObj.stop_lon),suppliedSpan:MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))) {
                        MapView(region:  MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude:self.stationObj.stop_lat, longitude:  self.stationObj.stop_lon),
                           latitudinalMeters: 75,
                           longitudinalMeters: 75), BrunswickLineCoordinates: brunswick, PennLineCoordinates: penn, CamdenLineCoordinates: camd, FredrickBranchLineCoordinates: fred,trains:trains, tripId: "Null").frame(width:geometry.size.width * 0.90,height:geometry.size.height*0.35).cornerRadius(15).padding(.bottom, 0)
                       }.accentColor(Color.black)

                        HStack {
                            HStack {
                                Text("Tracked Trains").fontWeight(Font.Weight.medium)
                            }.padding([.leading,.trailing],15).padding([.vertical,.horizontal],5).background(showAllTrains ? Color.gray : Color.orange).cornerRadius(25).onTapGesture{
                                showAllTrains = false
                            }
                            HStack {
                                Text("All Trains").fontWeight(Font.Weight.medium)
                            }.padding([.leading,.trailing],15).padding([.vertical,.horizontal],5).background(showAllTrains ? Color.orange : Color.gray).cornerRadius(25).onTapGesture{
                                showAllTrains = true
                            }
                        }
                if (!showAllTrains) {
                    List($trainsGoingToStation.indices, id: \.self) { i  in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(FormatTripId(tripId: trainsGoingToStation[i].tripId))
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text(RouteIdToName(routeId: trainsGoingToStation[i].line))
                                if (trainsGoingToStation[i].delay ?? 0 > 300) {
                                    Rectangle().frame(width: 10, height: 10, alignment: .center).foregroundColor(Color.red).cornerRadius(1000)
                                } else {
                                    Rectangle().frame(width: 10, height: 10, alignment: .center).foregroundColor(Color.green).cornerRadius(1000)
                                }
                                
                                Spacer()
                                HStack(spacing: 0) {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 24, weight: .light))
                                    
                                    NavigationLink(destination: NewTrainDetailedView(tripId: GetTrainsGoingToStation(stopId: stationObj.stop_id,trains:trains,details:details)[i].tripId)) {
                                        EmptyView()
                                    }.accentColor(Color.black)
                                    .frame(width: 0)
                                    .opacity(0)
                                }.onTapGesture {
                                    activeTrain = true
                                }
                                
                            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }.onAppear() {
                            print("list did appear 11/30")
                        }
                    }
                
                       
                    
                } else {
                    HStack{
                        Picker("Line", selection: $lineInput) {
                            Text("Penn ").tag(lineChoice.Penn)
                            Text("Camden").tag(lineChoice.Camden)
                            Text("Brunswick").tag(lineChoice.Brunswick)
                        }.background(CustomColors.MarcBlue).padding([.leading,.trailing],15).padding([.vertical,.horizontal],5).onChange(of: lineInput) { newValue in
                
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd/yyyy"
                            let formattedDate = dateFormatter.string(from: dateInput)
                            apiCall().getTimetable(lineName: lineInput.rawValue, date: formattedDate, direction: directionInput.rawValue) { (tt: [timetableResponse]?) in
                                if (!(tt ?? []).filter{$0.stop_name?.lowercased() ?? "" == stationObj.stop_name.lowercased()}.isEmpty && !(tt ?? []).filter{$0.stop_name?.lowercased() ?? "" == stationObj.stop_name.lowercased()}.isEmpty) {
                                    self.timetableTimes = (tt ?? []).filter{$0.stop_name?.lowercased() == stationObj.stop_name.lowercased()}[0].times ?? []
                                    self.timetableTrains = (tt ?? []).filter{$0.stop_name?.lowercased() == stationObj.stop_name.lowercased()}[0].trains ?? []
                                } else {
                                    self.timetableTimes = []
                                    self.timetableTrains = []
                                }

                                print(self.timetableTrains)
                            }
                        }
                        Picker("Direction", selection: $directionInput) {
                            Text("Outbound").tag(directionChocies.inbound)
                            Text("Inbound").tag(directionChocies.outbound)
                        }.background(CustomColors.MarcBlue).padding([.leading,.trailing],15).padding([.vertical,.horizontal],5).onChange(of: directionInput) { newValue in
                         
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd/yyyy"
                            let formattedDate = dateFormatter.string(from: dateInput)
                            apiCall().getTimetable(lineName: lineInput.rawValue, date: formattedDate, direction: directionInput.rawValue) { (tt: [timetableResponse]?) in
                                if (!(tt ?? []).filter{$0.stop_name?.lowercased() ?? "" == stationObj.stop_name.lowercased()}.isEmpty && !(tt ?? []).filter{$0.stop_name?.lowercased() ?? "" == stationObj.stop_name.lowercased()}.isEmpty) {
                                    self.timetableTimes = (tt ?? []).filter{$0.stop_name?.lowercased() ?? "" == stationObj.stop_name.lowercased()}[0].times ?? []
                                    self.timetableTrains = (tt ?? []).filter{$0.stop_name?.lowercased() ?? "" == stationObj.stop_name.lowercased()}[0].trains ?? []
                                }

                                print(self.timetableTrains)
                            }
                        }
                       
                    }
                    HStack {
                        DatePicker(
                               "",
                               selection: $dateInput,
                               displayedComponents: [.date]
                        )   .labelsHidden().environment(\.locale, Locale.init(identifier: "en")).onChange(of: dateInput) { newValue in
                      
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd/yyyy"
                            let formattedDate = dateFormatter.string(from: newValue)
                            apiCall().getTimetable(lineName: lineInput.rawValue, date: formattedDate, direction: directionInput.rawValue) { (tt: [timetableResponse]?) in
                                if (!(tt ?? []).isEmpty && (tt ?? [])[0].error == "true") {
                                    self.timetableTimes = []
                                    self.timetableTrains = []
                                    
                                }
                                if (!(tt ?? []).filter{$0.stop_name?.lowercased() ?? "" == stationObj.stop_name.lowercased()}.isEmpty && !(tt ?? []).filter{$0.stop_name?.lowercased() ?? "" == stationObj.stop_name.lowercased()}.isEmpty) {
                                    self.timetableTimes = (tt ?? []).filter{$0.stop_name?.lowercased() ?? "" == stationObj.stop_name.lowercased()}[0].times ?? []
                                    self.timetableTrains = (tt ?? []).filter{$0.stop_name?.lowercased() == stationObj.stop_name.lowercased()}[0].trains ?? []
                                }

                                print(self.timetableTrains)
                            }
                        }
                    }
                    
                    List(timetableTimes.indices) { i in
                        VStack(alignment: .leading) {
                            
                            HStack {
                                Text(timetableTrains[i] ?? "Error")
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                
                                Text(timetableTimes[i] ?? "Error")
                                Spacer()
                                Text(lineInput.rawValue).font(.system(size: 18))
                                
                            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                       Spacer()
                        }
                    }.id(timetableTimes)
                }
            
                 
                }
                Spacer()
        }.onAppear() {
            apiCall().getTrains { trains_tmp in
                apiCall().getTripUpdates { tripupdate_tmp in
                    trainsGoingToStation = GetTrainsGoingToStation(stopId: stationObj.stop_id,trains:trains_tmp ?? [],details:tripupdate_tmp ?? [])
                }
            }
            
        }
        }
    }


