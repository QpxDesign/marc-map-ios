//
//  TrainDetailedViewStatic.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/9/26.
//

import SwiftUI

struct TrainDetailedViewStatic: View {
    let trip_id: String
    let stations: [station]
    let favorites = getFavorites()
    @State var localFavState: Bool = false
    @State var stopTimeUpdates: [stopTimeUpdate] = []

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
        VStack {
            HStack {
                Text(FormatTripId(tripId: trip_id)).bold().multilineTextAlignment(.leading).foregroundColor(Color.white).font(.system(size: 34))
                Text("SCHEDULED").foregroundColor(Color.white).font(.system(size: 18)).monospaced()
                Spacer()
                Image(systemName: localFavState ? "star.fill" : "star").font(.system(size: 28)).foregroundStyle(Color.white).onTapGesture {
                    toggleFavorite(favorite: trip_id)
                    localFavState = !localFavState
                }
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 15).padding(.leading, 20).padding(.trailing, 20).background(CustomColors.MarcOrange).onAppear {
                localFavState = !favorites.filter { $0 == trip_id }.isEmpty
                apiCall().getSchedule(trip_id: trip_id) { tt in
                    stopTimeUpdates = tt ?? []
                }
            }
            if !stopTimeUpdates.isEmpty {
                if stopTimeUpdates[0].calendar != nil {
                    Text("Operates \(human_readable_calender(cal: stopTimeUpdates[0].calendar ?? []))").font(.system(size: 24))
                }
                VStack(alignment: .center) {
                    List(stopTimeUpdates) { stop in
                        HStack {
                            Text(GetStationFromStopId(stopID: Int(stop.stopId) ?? 0, stations: stations).pretty_stop_name)
                            Spacer()

                            Text(stop.arrival != nil ? formatDate(d: stop.arrival?.time ?? "") : stop.departure != nil ? formatDate(d: stop.departure?.time ?? "") : "Unknown").bold()
                        }

                    }.contentMargins(.top, 15)

                }.padding(.top, 0)

            } else {
                Text("Loading...").font(.system(size: 32))
                Spacer()
            }
        }
    }
}

#Preview {
    TrainDetailedViewStatic(trip_id: "Train452", stations: loadStations())
}

func human_readable_calender(cal: [String]) -> String {
    let daysOfWeek = ["Mondays", "Tuesdays", "Wednesdays", "Thursdays", "Fridays", "Saturdays", "Sundays"]
    var bytestring = ""
    for c in cal {
        bytestring += c
    }
    if bytestring == "1111100" {
        return "on Weekdays"
    }
    if bytestring == "1111111" {
        return "Everday"
    }
    var days: [String] = []
    for i in cal.indices {
        if i >= daysOfWeek.count {
            continue
        }
        if cal[i] == "1" {
            days.append(daysOfWeek[i])
        }
    }
    if days.count == 0 {
        return "Sporadically"
    }
    if days.count == 1 {
        return "on \(days[0])"
    }
    if days.count == 2 {
        return "on \(days[0]) and \(days[1])"
    }
    var msg = "on \(days[0]),"
    for i in days.indices {
        if i != 0 && i != days.count - 1 {
            msg += " \(days[i]),"
        }
    }
    msg += " and \(days[days.count - 1])"

    return msg
}
