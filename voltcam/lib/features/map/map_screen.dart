import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glassmorphism.dart';
import '../../domain/models/grid_zone_model.dart';
import '../../domain/models/incident_model.dart';

/// Ultra-minimalist dark map style for VoltCam.
/// Hides roads, POIs, transit, and street labels.
/// Only terrain, water bodies, and admin boundaries remain visible
/// so that power grid zone polygons stand out visually.
const String lightMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#F5F5F5"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#F5F5F5"}]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#BDBDBD"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#EEEEEE"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#E5E5E5"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9E9E9E"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#FFFFFF"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#DADADA"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9E9E9E"}]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [{"color": "#E5E5E5"}]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [{"color": "#EEEEEE"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#C9C9C9"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9E9E9E"}]
  }
]
''';

// State Provider for active grid zones
final gridZonesProvider = StateProvider<List<GridZoneModel>>((ref) {
  return const [
    GridZoneModel(
      zoneId: 'yaounde-biyem-assi',
      name: 'Yaoundé — Biyem-Assi',
      polygon: [
        {'lat': 3.8450, 'lng': 11.4800},
        {'lat': 3.8580, 'lng': 11.4820},
        {'lat': 3.8600, 'lng': 11.4980},
        {'lat': 3.8470, 'lng': 11.4960},
      ],
      activeIncidentCount: 4,
      status: 'CRITICAL',
    ),
    GridZoneModel(
      zoneId: 'yaounde-bastos',
      name: 'Yaoundé — Bastos',
      polygon: [
        {'lat': 3.8850, 'lng': 11.5000},
        {'lat': 3.8980, 'lng': 11.5030},
        {'lat': 3.8960, 'lng': 11.5180},
        {'lat': 3.8820, 'lng': 11.5140},
      ],
      activeIncidentCount: 0,
      status: 'NORMAL',
    ),
    GridZoneModel(
      zoneId: 'yaounde-melen',
      name: 'Yaoundé — Melen',
      polygon: [
        {'lat': 3.8600, 'lng': 11.4950},
        {'lat': 3.8720, 'lng': 11.4970},
        {'lat': 3.8710, 'lng': 11.5080},
        {'lat': 3.8590, 'lng': 11.5060},
      ],
      activeIncidentCount: 2,
      status: 'WARNING',
    ),
    GridZoneModel(
      zoneId: 'yaounde-mvog-ada',
      name: 'Yaoundé — Mvog-Ada',
      polygon: [
        {'lat': 3.8580, 'lng': 11.5200},
        {'lat': 3.8690, 'lng': 11.5220},
        {'lat': 3.8670, 'lng': 11.5340},
        {'lat': 3.8560, 'lng': 11.5310},
      ],
      activeIncidentCount: 1,
      status: 'WARNING',
    ),
    GridZoneModel(
      zoneId: 'yaounde-omnisport',
      name: 'Yaoundé — Omnisport (Mfandena)',
      polygon: [
        {'lat': 3.8810, 'lng': 11.5320},
        {'lat': 3.8940, 'lng': 11.5350},
        {'lat': 3.8920, 'lng': 11.5470},
        {'lat': 3.8790, 'lng': 11.5440},
      ],
      activeIncidentCount: 1,
      status: 'MAINTENANCE',
    ),
    GridZoneModel(
      zoneId: 'yaounde-cite-verte',
      name: 'Yaoundé — Cité Verte',
      polygon: [
        {'lat': 3.8700, 'lng': 11.4820},
        {'lat': 3.8820, 'lng': 11.4840},
        {'lat': 3.8800, 'lng': 11.4950},
        {'lat': 3.8680, 'lng': 11.4930},
      ],
      activeIncidentCount: 0,
      status: 'NORMAL',
    ),
    GridZoneModel(
      zoneId: 'douala-akwa',
      name: 'Douala — Akwa',
      polygon: [
        {'lat': 4.0400, 'lng': 9.6900},
        {'lat': 4.0550, 'lng': 9.6900},
        {'lat': 4.0550, 'lng': 9.7100},
        {'lat': 4.0400, 'lng': 9.7100},
      ],
      activeIncidentCount: 2,
      status: 'WARNING',
    ),
    GridZoneModel(
      zoneId: 'douala-bonanjo',
      name: 'Douala — Bonanjo',
      polygon: [
        {'lat': 4.0300, 'lng': 9.6800},
        {'lat': 4.0450, 'lng': 9.6800},
        {'lat': 4.0450, 'lng': 9.6950},
        {'lat': 4.0300, 'lng': 9.6950},
      ],
      activeIncidentCount: 1,
      status: 'MAINTENANCE',
    ),
  ];
});

// State Provider for incidents
final incidentsProvider = StateProvider<List<IncidentModel>>((ref) {
  final now = DateTime.now();
  return [
    IncidentModel(
      incidentId: 'inc-001',
      zoneId: 'yaounde-biyem-assi',
      type: 'OUTAGE',
      status: 'CONFIRMED',
      startedAt: now.subtract(const Duration(minutes: 45)),
      confidenceScore: 94,
      independentDeviceCount: 8,
      publicSummary: 'Coupure générale signalée par 8 boîtiers IoT indépendants.',
      mapLayer: 'OUTAGES',
      updatedAt: now,
    ),
    IncidentModel(
      incidentId: 'inc-002',
      zoneId: 'douala-akwa',
      type: 'INSTABILITY',
      status: 'CONFIRMED',
      startedAt: now.subtract(const Duration(minutes: 20)),
      confidenceScore: 82,
      independentDeviceCount: 5,
      publicSummary: 'Fluctuations importantes de tension (170V-250V).',
      mapLayer: 'INSTABILITIES',
      updatedAt: now,
    ),
    IncidentModel(
      incidentId: 'inc-003',
      zoneId: 'douala-bonanjo',
      type: 'MAINTENANCE',
      status: 'CONFIRMED',
      startedAt: now.subtract(const Duration(hours: 2)),
      confidenceScore: 100,
      independentDeviceCount: 12,
      publicSummary: 'Maintenance programmée sur le poste HTA Bonanjo Nord.',
      mapLayer: 'MAINTENANCE',
      updatedAt: now,
    ),
  ];
});

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  GridZoneModel? _selectedZone;
  String _activeFilter = 'ALL'; // ALL, OUTAGE, INSTABILITY, MAINTENANCE, NORMAL

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.18, end: 0.48).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(3.8480, 11.5021),
    zoom: 11.5,
  );

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CRITICAL':
      case 'OUTAGE':
        return AppColors.dangerRed;
      case 'WARNING':
      case 'INSTABILITY':
        return AppColors.voltYellow;
      case 'MAINTENANCE':
        return AppColors.maintenancePurple;
      case 'NORMAL':
      default:
        return AppColors.successGreen;
    }
  }

  Set<Polygon> _buildPolygons(List<GridZoneModel> zones) {
    final Set<Polygon> polygons = {};
    for (final zone in zones) {
      if (_activeFilter != 'ALL') {
        if (_activeFilter == 'OUTAGE' && zone.status != 'CRITICAL') continue;
        if (_activeFilter == 'INSTABILITY' && zone.status != 'WARNING') continue;
        if (_activeFilter == 'MAINTENANCE' && zone.status != 'MAINTENANCE') continue;
        if (_activeFilter == 'NORMAL' && zone.status != 'NORMAL') continue;
      }

      final points = zone.polygon
          .map((p) => LatLng(p['lat']!, p['lng']!))
          .toList();
      final color = _getStatusColor(zone.status);

      // Apply pulsing opacity for CRITICAL outage zones
      final opacity = (zone.status.toUpperCase() == 'CRITICAL')
          ? _pulseAnimation.value
          : 0.28;

      polygons.add(
        Polygon(
          polygonId: PolygonId(zone.zoneId),
          points: points,
          fillColor: color.withOpacity(opacity),
          strokeColor: color,
          strokeWidth: (zone.status.toUpperCase() == 'CRITICAL') ? 3 : 2,
          consumeTapEvents: true,
          onTap: () {
            setState(() {
              _selectedZone = zone;
            });
            _showZoneDetailModal(zone);
          },
        ),
      );
    }
    return polygons;
  }

  Set<Marker> _buildMarkers(List<GridZoneModel> zones, List<IncidentModel> incidents) {
    final Set<Marker> markers = {};

    // Center markers for zones
    for (final zone in zones) {
      if (zone.polygon.isEmpty) continue;
      double avgLat = 0;
      double avgLng = 0;
      for (final p in zone.polygon) {
        avgLat += p['lat']!;
        avgLng += p['lng']!;
      }
      avgLat /= zone.polygon.length;
      avgLng /= zone.polygon.length;

      double hue = BitmapDescriptor.hueGreen;
      if (zone.status == 'CRITICAL') hue = BitmapDescriptor.hueRed;
      if (zone.status == 'WARNING') hue = BitmapDescriptor.hueYellow;
      if (zone.status == 'MAINTENANCE') hue = BitmapDescriptor.hueViolet;

      markers.add(
        Marker(
          markerId: MarkerId('marker_${zone.zoneId}'),
          position: LatLng(avgLat, avgLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: zone.name,
            snippet: 'Statut: ${zone.status} (${zone.activeIncidentCount} incident(s))',
          ),
          onTap: () {
            setState(() {
              _selectedZone = zone;
            });
            _showZoneDetailModal(zone);
          },
        ),
      );
    }

    return markers;
  }

  void _showZoneDetailModal(GridZoneModel zone) {
    final incidents = ref
        .read(incidentsProvider)
        .where((i) => i.zoneId == zone.zoneId)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final color = _getStatusColor(zone.status);
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.glassBorder, width: 1),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Zone Statut: ${zone.status}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const GlassBadge(
                    label: 'GridTrust 94%',
                    icon: Icons.verified_user_rounded,
                    color: AppColors.electricCyan,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Incidents Actifs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              if (incidents.isEmpty)
                const GlassCard(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: AppColors.successGreen),
                      SizedBox(width: 10),
                      Text(
                        'Aucun incident majeur signalé dans cette zone.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ...incidents.map((inc) => GlassCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GlassBadge(
                                label: inc.type,
                                color: _getStatusColor(inc.type),
                              ),
                              Text(
                                '${inc.confidenceScore}% Confiance',
                                style: const TextStyle(
                                  color: AppColors.electricCyan,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            inc.publicSummary,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.sensors_rounded, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '${inc.independentDeviceCount} boîtiers IoT connectés',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showReportIncidentDialog(zone);
                  },
                  label: 'Signaler un incident dans cette zone',
                  icon: Icons.report_problem_outlined,
                  color: AppColors.voltYellow,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showReportIncidentDialog(GridZoneModel zone) {
    final textController = TextEditingController();
    String incidentType = 'OUTAGE';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
          title: Text('Signaler un incident — ${zone.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Type d\'anomalie constatée :',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: incidentType,
                dropdownColor: AppColors.surface,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'OUTAGE', child: Text('Coupure totale (Outage)')),
                  DropdownMenuItem(value: 'INSTABILITY', child: Text('Instabilité / Baisse de tension')),
                  DropdownMenuItem(value: 'MAINTENANCE', child: Text('Travaux / Maintenance')),
                ],
                onChanged: (val) {
                  if (val != null) incidentType = val;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Décrivez brièvement la situation (ex: Coupure depuis 10 minutes...)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final newInc = IncidentModel(
                  incidentId: 'inc-${DateTime.now().millisecondsSinceEpoch}',
                  zoneId: zone.zoneId,
                  type: incidentType,
                  status: 'CONFIRMED',
                  startedAt: DateTime.now(),
                  confidenceScore: 88,
                  independentDeviceCount: 1,
                  publicSummary: textController.text.trim().isEmpty
                      ? 'Signalement citoyen direct enregistré.'
                      : textController.text.trim(),
                  mapLayer: incidentType == 'OUTAGE' ? 'OUTAGES' : 'INSTABILITIES',
                  updatedAt: DateTime.now(),
                );

                ref.read(incidentsProvider.notifier).update((state) => [newInc, ...state]);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Signalement envoyé pour ${zone.name} ! GridTrust validera le consensus.'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = _activeFilter == value;
    return ChoiceChip(
        label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: AppColors.surface.withOpacity(0.7),
      side: BorderSide(color: isSelected ? color : AppColors.glassBorderSubtle),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _activeFilter = value;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(gridZonesProvider);
    final incidents = ref.watch(incidentsProvider);
    final polygons = _buildPolygons(zones);
    final markers = _buildMarkers(zones, incidents);

    return Scaffold(
      key: const Key('map_screen_scaffold'),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_rounded, color: AppColors.electricCyan, size: 24),
            SizedBox(width: 8),
            Text('Carte Live Grid Monitoring'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppColors.electricCyan,
            ),
            onPressed: () {
              final current = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(current == ThemeMode.dark ? 'Thème Clair activé' : 'Thème Sombre activé')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.electricCyan),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Actualisation des calques et zones en temps réel...')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map View
          GoogleMap(
            key: const Key('google_map_widget'),
            initialCameraPosition: _initialCamera,
            polygons: polygons,
            markers: markers,
            onMapCreated: (GoogleMapController controller) {
              controller.setMapStyle(lightMapStyle);
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),

          // Top Filter Bar Overlay
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tous', 'ALL', AppColors.electricCyan),
                  const SizedBox(width: 6),
                  _buildFilterChip('Coupures (Outage)', 'OUTAGE', AppColors.dangerRed),
                  const SizedBox(width: 6),
                  _buildFilterChip('Instabilités', 'INSTABILITY', AppColors.voltYellow),
                  const SizedBox(width: 6),
                  _buildFilterChip('Maintenance', 'MAINTENANCE', AppColors.maintenancePurple),
                  const SizedBox(width: 6),
                  _buildFilterChip('Normal', 'NORMAL', AppColors.successGreen),
                ],
              ),
            ),
          ),

          // Zone Selection Summary Overlay Card
          if (_selectedZone != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: GlassCard(
                onTap: () => _showZoneDetailModal(_selectedZone!),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _getStatusColor(_selectedZone!.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedZone!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${_selectedZone!.activeIncidentCount} incident(s) actif(s) — Appuyez pour détails',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.electricCyan),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
