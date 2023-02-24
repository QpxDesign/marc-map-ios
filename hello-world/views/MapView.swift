import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let trainCoords: CLLocationCoordinate2D
  let region: MKCoordinateRegion
  let BrunswickLineCoordinates : [CLLocationCoordinate2D]
    let PennLineCoordinates : [CLLocationCoordinate2D]
    let CamdenLineCoordinates : [CLLocationCoordinate2D]
    let FredrickBranchLineCoordinates : [CLLocationCoordinate2D]
    let tripId : String
    
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.region = region
    let BrunswickPolyline = MKPolyline(coordinates: BrunswickLineCoordinates, count: BrunswickLineCoordinates.count)
    let PennPolyline = MKPolyline(coordinates: PennLineCoordinates, count: PennLineCoordinates.count)
    let CamdenPolyline = MKPolyline(coordinates: CamdenLineCoordinates, count: CamdenLineCoordinates.count)
    let FredrickPolyline = MKPolyline(coordinates: FredrickBranchLineCoordinates, count: FredrickBranchLineCoordinates.count)
    
    
    let annotation = MKPointAnnotation()
    annotation.coordinate = trainCoords
    annotation.title = FormatTripId(tripId: tripId)
    let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
    mapView.setRegion(coordinateRegion, animated: true)
    mapView.addAnnotation(annotation)

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
