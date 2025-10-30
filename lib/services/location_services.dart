import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart' as geo;

class LocationService {
  final loc.Location _location = loc.Location();


  // method publik untuk dipanggil dari CartScreen
  Future<loc.LocationData?> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        _showSnack(context, 'Layanan lokasi tidak aktif');
        return null;
      }
    }

    loc.PermissionStatus permission = await _location.hasPermission();
    if (permission == loc.PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != loc.PermissionStatus.granted) {
        _showSnack(context, 'Izin lokasi ditolak');
        return null;
      }
    }

    try {
      final data = await _location.getLocation();
      debugPrint('LBS: lokasi: ${data.latitude}, ${data.longitude}');
      return data;
    } catch (e) {
      _showSnack(context, 'Gagal mendapatkan lokasi: $e');
      return null;
    }
  }

  // method publik untuk konversi koordinat ke alamat
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isEmpty) return null;

      final geo.Placemark p = placemarks.first;
      final parts = <String>[
        if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
        if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
        if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
        if ((p.administrativeArea ?? '').trim().isNotEmpty)
          p.administrativeArea!.trim(),
        if ((p.postalCode ?? '').trim().isNotEmpty) p.postalCode!.trim(),
      ];
      final address = parts.join(', ');
      debugPrint('LBS: alamat: $address');
      return address.isEmpty ? null : address;
    } catch (e) {
      debugPrint('LBS: geocoding error: $e');
      return null;
    }
  }

  Future<void> openDirectionsInGoogleMaps(BuildContext context) async {
    try {
      final String url = 'https://maps.app.goo.gl/52Xeaqt7x59PJwP59';
      final uri = Uri.parse(url);
      final ok = await canLaunchUrl(uri);
      if (!ok) throw 'Tidak bisa membuka Maps';
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showSnack(context, 'Error: $e');
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
