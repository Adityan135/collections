import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:login/main.dart';
import 'package:search_map_location/search_map_location.dart';
import 'package:search_map_location/utils/google_search/geo_location.dart';
import 'package:search_map_location/utils/google_search/place.dart';
import 'package:search_map_location/utils/google_search/place_type.dart';


class GoogleMapsClass extends StatefulWidget {
  const GoogleMapsClass({Key? key}) : super(key: key);
  @override
  _GoogleMaps createState()=>_GoogleMaps();
}
class _GoogleMaps extends State<GoogleMapsClass> {
  final Set<Polyline> polyline = {};
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  late GoogleMapController _controller;
 // final _directions = directions.GoogleMapsDirections(apiKey: "AIzaSyDYBLQtOqPXWnn4smq-CnTeM3Up6xp3Zwc");
  //var overviewPolylines;
  List<Marker> myMarkers=[Marker(
    markerId: MarkerId(
      'Current Location'
    ),
    position: LatLng(MyAppState.position.latitude,MyAppState.position.longitude)
  )];
  GoogleMapPolyline googleMapPolyline =
  GoogleMapPolyline(apiKey: "AIzaSyDYBLQtOqPXWnn4smq-CnTeM3Up6xp3Zwc");
  List<LatLng> routeCoords=[];
  @override
  void initState(){
    super.initState();
    //getsomePoints();
    routeCoords.add(LatLng(MyAppState.position.latitude,MyAppState.position.longitude));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SearchLocation (apiKey: "AIzaSyDYBLQtOqPXWnn4smq-CnTeM3Up6xp3Zwc",
                  placeholder: 'Enter a location name',
                  hasClearButton: true,
                  onSelected: (Place place) async{
                  Geolocation? geolocation=await place.geolocation;
                  print(geolocation?.coordinates.latitude);
                  if(routeCoords.length==1){
                  routeCoords.add(LatLng(geolocation?.coordinates.latitude, geolocation?.coordinates.longitude));}
                  else{
                    routeCoords[1]=LatLng(geolocation?.coordinates.latitude, geolocation?.coordinates.longitude);
                  }
                 setState(() {
                   _controller.moveCamera(CameraUpdate.zoomTo(10.0));
                   if(myMarkers.length>1){
                     myMarkers.remove(myMarkers[myMarkers.length-1]);
                   }
                   myMarkers.add(Marker(
                       markerId: MarkerId(place.placeId.toString()),
                       position: LatLng(geolocation?.coordinates.latitude,geolocation?.coordinates.longitude)

                   ));
                 getDirections();
                 });
                 /* await googleMapPolyline.getCoordinatesWithLocation(origin: routeCoords[0], destination: routeCoords[1], mode: RouteMode.driving);
                  setState(() {

                  });
                  print(myMarkers);*/
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SizedBox(
                height: 600.0,
                child: GoogleMap(
                  markers: Set.from(myMarkers),
                  initialCameraPosition:
                  CameraPosition(target: LatLng(13.0032515, 80.2110552), zoom: 18.0),

                  mapType: MapType.normal,
                  polylines: Set<Polyline>.of(polylines.values), //polylines//map type
                  onMapCreated: (controller) { //method called when map is created
                    setState(() {
                      _controller = controller;
                    });
                  },
                ),
            ),
              )],
          ),
        )
    );
  }



  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyDYBLQtOqPXWnn4smq-CnTeM3Up6xp3Zwc',
      PointLatLng(routeCoords[0].latitude, routeCoords[0].longitude),
      PointLatLng(routeCoords[1].latitude, routeCoords[1].longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }
}