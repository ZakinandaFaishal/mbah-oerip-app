import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../utils/snackbar_utils.dart';
import '../theme.dart';

class UserTimeZoneInfo {
  final String zoneId; // contoh: Asia/Jakarta, Asia/Makassar, Europe/London
  final String label; // label ramah pengguna
  final String? address; // alamat singkat, opsional
  UserTimeZoneInfo({required this.zoneId, required this.label, this.address});
}

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
    showModernSnackBar(
      context,
      message: msg,
      icon: Icons.error_outline,
      color: AppTheme.primaryRed,
    );
  }

  // Helper: mapping placemark -> zona waktu + label
  UserTimeZoneInfo _mapPlacemarkToZone(geo.Placemark p, {String? address}) {
    final country = (p.country ?? '').toLowerCase();
    final admin = (p.administrativeArea ?? '').toLowerCase();

    // Negara spesifik
    if (country.contains('united kingdom') || admin.contains('london')) {
      return UserTimeZoneInfo(
        zoneId: 'Europe/London',
        label: 'London',
        address: address,
      );
    }
    if (country.contains('japan') || admin.contains('tokyo')) {
      return UserTimeZoneInfo(
        zoneId: 'Asia/Tokyo',
        label: 'Jepang (Tokyo)',
        address: address,
      );
    }

    // Indonesia: WIB/WITA/WIT via provinsi
    final wita = [
      'bali',
      'nusa tenggara barat',
      'nusa tenggara timur',
      'kalimantan selatan',
      'kalimantan timur',
      'kalimantan utara',
      'sulawesi',
      'gorontalo',
      'sulawesi selatan',
      'sulawesi barat',
      'sulawesi tengah',
      'sulawesi tenggara',
      'sulawesi utara',
    ];
    final wit = [
      'papua',
      'papua barat',
      'papua tengah',
      'papua pegunungan',
      'papua selatan',
      'maluku',
      'maluku utara',
      'papua barat daya',
    ];

    if (wita.any((x) => admin.contains(x))) {
      return UserTimeZoneInfo(
        zoneId: 'Asia/Makassar',
        label: 'WITA (Makassar)',
        address: address,
      );
    }
    if (wit.any((x) => admin.contains(x))) {
      return UserTimeZoneInfo(
        zoneId: 'Asia/Jayapura',
        label: 'WIT (Jayapura)',
        address: address,
      );
    }
    if (country.contains('indonesia')) {
      return UserTimeZoneInfo(
        zoneId: 'Asia/Jakarta',
        label: 'WIB (Jakarta)',
        address: address,
      );
    }

    // Default
    return UserTimeZoneInfo(
      zoneId: 'Asia/Jakarta',
      label: 'WIB (Jakarta)',
      address: address,
    );
  }

  // Deteksi zona waktu user berbasis lokasi saat ini
  Future<UserTimeZoneInfo> detectUserTimeZone(BuildContext context) async {
    final data = await getCurrentLocation(context);
    if (data?.latitude == null || data?.longitude == null) {
      return UserTimeZoneInfo(zoneId: 'Asia/Jakarta', label: 'WIB (Jakarta)');
    }
    final lat = data!.latitude!;
    final lng = data.longitude!;
    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = [
          if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
          if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
          if ((p.administrativeArea ?? '').trim().isNotEmpty)
            p.administrativeArea!.trim(),
          if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),
        ].where((e) => e.isNotEmpty).join(', ');
        return _mapPlacemarkToZone(p, address: address);
      }
    } catch (_) {}
    return UserTimeZoneInfo(zoneId: 'Asia/Jakarta', label: 'WIB (Jakarta)');
  }

  // NEW: Tentukan zona waktu dari input alamat/kota pengguna
  Future<UserTimeZoneInfo> resolveTimeZoneFromQuery(
    BuildContext context,
    String query,
  ) async {
    try {
      final locs = await geo.locationFromAddress(query);
      if (locs.isEmpty) throw 'Lokasi tidak ditemukan';
      final lat = locs.first.latitude;
      final lng = locs.first.longitude;
      final placemarks = await geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = [
          if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
          if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
          if ((p.administrativeArea ?? '').trim().isNotEmpty)
            p.administrativeArea!.trim(),
          if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),
        ].where((e) => e.isNotEmpty).join(', ');
        return _mapPlacemarkToZone(p, address: address);
      }
    } catch (e) {
      _showSnack(context, 'Lokasi tidak ditemukan');
    }
    return UserTimeZoneInfo(zoneId: 'Asia/Jakarta', label: 'WIB (Jakarta)');
  }

  // NEW: Tentukan zona waktu dari koordinat (hasil pilih di peta)
  Future<UserTimeZoneInfo> resolveTimeZoneFromLatLng(
    BuildContext context,
    double lat,
    double lng,
  ) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = [
          if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
          if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
          if ((p.administrativeArea ?? '').trim().isNotEmpty)
            p.administrativeArea!.trim(),
          if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),
        ].where((e) => e.isNotEmpty).join(', ');
        return _mapPlacemarkToZone(p, address: address);
      }
    } catch (_) {}
    return UserTimeZoneInfo(zoneId: 'Asia/Jakarta', label: 'WIB (Jakarta)');
  }
}
