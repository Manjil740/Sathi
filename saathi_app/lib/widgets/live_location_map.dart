import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/emergency.dart';
import '../models/responder.dart';

class LiveLocationMap extends StatelessWidget {
  const LiveLocationMap({
    super.key,
    required this.emergencyLocation,
    required this.responders,
  });

  final EmergencyLocation emergencyLocation;
  final List<ResponderAssignment> responders;

  @override
  Widget build(BuildContext context) {
    final victimPosition = LatLng(emergencyLocation.latitude, emergencyLocation.longitude);
    final responderMarkers = responders.asMap().entries.map((entry) {
      final index = entry.key;
      final responder = entry.value;
      return Marker(
        markerId: MarkerId(responder.userId),
        position: LatLng(
          emergencyLocation.latitude + (0.001 * (index + 1)),
          emergencyLocation.longitude + (index.isEven ? 0.001 : -0.001),
        ),
        infoWindow: InfoWindow(title: responder.name, snippet: '${responder.distanceMeters.round()}m away'),
      );
    }).toSet();

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('victim'),
        position: victimPosition,
        infoWindow: const InfoWindow(title: 'Victim', snippet: 'Distress location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      ...responderMarkers,
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 240,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: victimPosition, zoom: 15),
          markers: markers,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}
