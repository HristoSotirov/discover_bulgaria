//
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import '../models/landmark_model.dart';
// import '../services/landmark_service.dart';
// import 'package:url_launcher/url_launcher.dart';
//
//
// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? mapController;
//   LatLng? currentPosition;
//   final Set<Marker> _markers = {};
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     await _getLocation();
//     await _loadLandmarks();
//   }
//
//   Future<void> _getLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//       permission = await Geolocator.requestPermission();
//       if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
//         return;
//       }
//     }
//
//     final pos = await Geolocator.getCurrentPosition();
//     if (!mounted) return;
//
//     setState(() {
//       currentPosition = LatLng(pos.latitude, pos.longitude);
//     });
//   }
//
//   Future<void> _loadLandmarks() async {
//     try {
//       final landmarks = await LandmarkService().getAllLandmarks();
//
//       setState(() {
//         for (final landmark in landmarks) {
//           _markers.add(
//             Marker(
//               markerId: MarkerId(landmark.id ?? landmark.name),
//               position: LatLng(landmark.latitude, landmark.longitude),
//               icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//               onTap: () => _showCustomLandmarkPopup(context, landmark),
//               consumeTapEvents: true,
//             ),
//           );
//
//
//         }
//         isLoading = false;
//       });
//     } catch (e) {
//       print("Error loading landmarks: $e");
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     if (currentPosition == null || isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return GoogleMap(
//       onMapCreated: (controller) => mapController = controller,
//       initialCameraPosition: CameraPosition(
//         target: currentPosition!,
//         zoom: 12,
//       ),
//       myLocationEnabled: true,
//       myLocationButtonEnabled: true,
//       markers: _markers,
//     );
//   }
//
//   void _showCustomLandmarkPopup(BuildContext context, LandmarkModel landmark) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       backgroundColor: Colors.teal.shade700,
//       builder: (_) => Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               landmark.name,
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal.shade500,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   onPressed: () {
//                     Navigator.pop(context);
//                     _showLandmarkDescription(context, landmark);
//                   },
//                   child: const Text("See more"),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal.shade300,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   onPressed: () {
//                     final url = Uri.encodeFull(
//                       'https://www.google.com/maps/dir/?api=1&destination=${landmark.latitude},${landmark.longitude}',
//                     );
//                     launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//                   },
//                   child: const Text("Navigate"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showLandmarkDescription(BuildContext context, LandmarkModel landmark) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(landmark.name),
//         content: Text(landmark.description ?? 'No description available.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Close"),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/landmark_model.dart';
import '../services/landmark_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng? currentPosition;
  final Set<Marker> _markers = {};
  bool isLoading = true;

  LandmarkModel? selectedLandmark;
  bool showPopup = false;
  bool expanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _getLocation();
    await _loadLandmarks();
  }

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
        return;
      }
    }

    final pos = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      currentPosition = LatLng(pos.latitude, pos.longitude);
    });
  }

  Future<void> _loadLandmarks() async {
    try {
      final landmarks = await LandmarkService().getAllLandmarks();

      setState(() {
        for (final landmark in landmarks) {
          _markers.add(
            Marker(
              markerId: MarkerId(landmark.id ?? landmark.name),
              position: LatLng(landmark.latitude, landmark.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              consumeTapEvents: true,
              onTap: () {
                setState(() {
                  selectedLandmark = landmark;
                  showPopup = true;
                  expanded = false;
                });
              },
            ),
          );
        }
        isLoading = false;
      });
    } catch (e) {
      print("Error loading landmarks: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.getColors(isDark);

    if (currentPosition == null || isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) => mapController = controller,
          initialCameraPosition: CameraPosition(
            target: currentPosition!,
            zoom: 12,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _markers,
        ),
        if (showPopup && selectedLandmark != null)
          Positioned(
            bottom: 300,
            left: 30,
            right: 30,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors['box'],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedLandmark!.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colors['text'],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showPopup = false;
                            expanded = false;
                          });
                        },
                        icon: Icon(Icons.close, color: colors['text']),
                      )
                    ],
                  ),
                  if (expanded) ...[
                    const SizedBox(height: 8),
                    Text(
                      selectedLandmark!.description ?? 'No description available.',
                      style: TextStyle(color: colors['text']),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors['button'],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() {
                            expanded = !expanded;
                          });
                        },
                        child: Text(expanded ? "Hide info" : "See more"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors['accent'],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          final url = Uri.encodeFull(
                            'https://www.google.com/maps/dir/?api=1&destination=${selectedLandmark!.latitude},${selectedLandmark!.longitude}',
                          );
                          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        },
                        child: const Text("Navigate"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  }
