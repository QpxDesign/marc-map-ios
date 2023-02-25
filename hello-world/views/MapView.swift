import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI

struct MapView: UIViewRepresentable {
    let region: MKCoordinateRegion
    let BrunswickLineCoordinates : [CLLocationCoordinate2D]
    let PennLineCoordinates : [CLLocationCoordinate2D]
    let CamdenLineCoordinates : [CLLocationCoordinate2D]
    let FredrickBranchLineCoordinates : [CLLocationCoordinate2D]
    @State var trains : [Train]
    let tripId: String
    var timer = Timer()
    func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()

        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.backgroundColor = UIColor(white: 0, alpha: 0.8).cgColor
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.layer.position.x = UIScreen.main.bounds.width-25;
        button.layer.position.y = UIScreen.main.bounds.height-125;
        mapView.addSubview(button)

    mapView.delegate = context.coordinator
    mapView.region = region
    let BrunswickPolyline = MKPolyline(coordinates: BrunswickLineCoordinates, count: BrunswickLineCoordinates.count)
    let PennPolyline = MKPolyline(coordinates: PennLineCoordinates, count: PennLineCoordinates.count)
    let CamdenPolyline = MKPolyline(coordinates: CamdenLineCoordinates, count: CamdenLineCoordinates.count)
        // get user location from ip
    let FredrickPolyline = MKPolyline(coordinates: FredrickBranchLineCoordinates, count: FredrickBranchLineCoordinates.count)
        apiCall().getTrains { (trains) in
            for t in trains {
                 if (!mapView.annotations.filter{$0.title == FormatTripId(tripId: t.vehicle.trip.tripId) }.isEmpty) {
                    if let annotation = mapView.annotations.filter{$0.title == FormatTripId(tripId: t.vehicle.trip.tripId) }[0] as? MKPointAnnotation {
                        annotation.coordinate = CLLocationCoordinate2D(latitude: t.vehicle.position.latitude, longitude: t.vehicle.position.longitude)
                    }
                } else {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: t.vehicle.position.latitude, longitude: t.vehicle.position.longitude)
                    annotation.title = FormatTripId(tripId: t.vehicle.trip.tripId)
                    if (tripId != "Null" && t.vehicle.trip.tripId == tripId) {
                        let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                    }
                    let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
                    mapView.addAnnotation(annotation)
                }
            }
        }
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
            apiCall().getTrains { (trains) in
                //add all train
                  for t in trains {
                      if (!mapView.annotations.filter{$0.title == FormatTripId(tripId: t.vehicle.trip.tripId) }.isEmpty) {
                          if let annotation = mapView.annotations.filter{$0.title == FormatTripId(tripId: t.vehicle.trip.tripId) }[0] as? MKPointAnnotation {
                              annotation.coordinate = CLLocationCoordinate2D(latitude: t.vehicle.position.latitude, longitude: t.vehicle.position.longitude)
                              if (tripId != "Null" && t.vehicle.trip.tripId == tripId) {
                                  let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                                  mapView.setRegion(coordinateRegion, animated: true)
                              }
                           
                          }
                    
                      } else {
                          let annotation = MKPointAnnotation()
                          annotation.coordinate = CLLocationCoordinate2D(latitude: t.vehicle.position.latitude, longitude: t.vehicle.position.longitude)
                          annotation.title = FormatTripId(tripId: t.vehicle.trip.tripId)
                          let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                          if (tripId != "null" && t.vehicle.trip.tripId == tripId) {
                              mapView.setRegion(coordinateRegion, animated: true)
                          }
                          let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
                          mapView.addAnnotation(annotation)
                      }
                       
            
                      
                  }
                self.trains = trains
            }
        }

      
      
   
    
    //add stations
      if let url = Bundle.main.url(forResource: "StopData", withExtension: "json") {
          do {
              let data = try Data(contentsOf: url)
              let decoder = JSONDecoder()
              let jsonData = try decoder.decode([station].self, from: data)
              for i in jsonData {
                  let annotation = MKPointAnnotation()
                  annotation.coordinate = CLLocationCoordinate2D(latitude: i.stop_lat, longitude: i.stop_lon)
                  annotation.title = i.stop_name ?? "error"
                  mapView.addAnnotation(annotation)
              }
           
          } catch {
              print("error:\(error)")
          }
      }

    mapView.addOverlay(BrunswickPolyline)
    mapView.addOverlay(PennPolyline)
    mapView.addOverlay(CamdenPolyline)
    mapView.addOverlay(FredrickPolyline)

    return mapView
  }

  func updateUIView(_ view: MKMapView, context: Context) {

  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

}

class Coordinator: NSObject, MKMapViewDelegate {
  var parent: MapView

  init(_ parent: MapView) {
    self.parent = parent
  }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var title = annotation.title ?? ""
        if (title == "My Location") {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.frame.size = CGSize(width: 25, height: 25)
            annotationView.glyphImage = UIImage(systemName: "circle.fill")
            annotationView.markerTintColor = UIColor.systemBlue
            annotationView.layer.cornerRadius = 80
            return annotationView
        }
        else if (title!.contains("Train")) {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.markerTintColor = UIColor.clear
            // Resize image
              let pinImage = UIImage(named: "TrainIcon")
              let size = CGSize(width: 60, height: 60)
              UIGraphicsBeginImageContext(size)
              pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
              let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            annotationView.image = resizedImage
            annotationView.glyphImage = UIImage(systemName: "circle.fill")
            annotationView.backgroundColor = UIColor.clear
            annotationView.layer.cornerRadius = 80
            annotationView.displayPriority = .defaultHigh
            annotationView.zPriority = MKAnnotationViewZPriority(999)
            return annotationView
        } else {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
               annotationView.markerTintColor = UIColor.blue
            annotationView.glyphImage = UIImage(named: "StationIcon")
            annotationView.frame.size = CGSize(width: 100, height: 100)
            annotationView.backgroundColor = UIColor.red
            annotationView.layer.cornerRadius = 80
            annotationView.displayPriority = .defaultLow
            annotationView.zPriority = MKAnnotationViewZPriority(1)
            return annotationView
        }
     
           
    }
   
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let routePolyline = overlay as? MKPolyline {
      let renderer = MKPolylineRenderer(polyline: routePolyline)
        renderer.strokeColor = UIColor(CustomColors.PennColor)
      renderer.lineWidth = 10
      return renderer
    }
    return MKOverlayRenderer()
  }
    
}
