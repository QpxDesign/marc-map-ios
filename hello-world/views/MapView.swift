import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let region: MKCoordinateRegion
    let BrunswickLineCoordinates : [CLLocationCoordinate2D]
    let PennLineCoordinates : [CLLocationCoordinate2D]
    let CamdenLineCoordinates : [CLLocationCoordinate2D]
    let FredrickBranchLineCoordinates : [CLLocationCoordinate2D]
    @State var trains : [Train]
    let tripId: String
    
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.region = region
    let BrunswickPolyline = MKPolyline(coordinates: BrunswickLineCoordinates, count: BrunswickLineCoordinates.count)
    let PennPolyline = MKPolyline(coordinates: PennLineCoordinates, count: PennLineCoordinates.count)
    let CamdenPolyline = MKPolyline(coordinates: CamdenLineCoordinates, count: CamdenLineCoordinates.count)
    let FredrickPolyline = MKPolyline(coordinates: FredrickBranchLineCoordinates, count: FredrickBranchLineCoordinates.count)
      
    //add all train
      for t in trains {
          let annotation = MKPointAnnotation()
          annotation.coordinate = CLLocationCoordinate2D(latitude: t.vehicle.position.latitude, longitude: t.vehicle.position.longitude)
          annotation.title = FormatTripId(tripId: t.vehicle.trip.tripId)
          let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
          if (tripId != "null" && t.vehicle.trip.tripId == tripId) {
              mapView.setRegion(coordinateRegion, animated: true)
          }
       
          mapView.addAnnotation(annotation)
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
