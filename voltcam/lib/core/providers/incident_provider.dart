import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/incident_model.dart';
import '../../domain/models/grid_zone_model.dart';

/// State representation for Active Grid Incidents and Zone Overlays.
class IncidentState {
  final List<IncidentModel> activeIncidents;
  final List<GridZoneModel> zones;
  final String? selectedZoneId;
  final String selectedFilter; // e.g. ALL, OUTAGES, INSTABILITY
  final bool isLoading;
  final String? error;

  const IncidentState({
    this.activeIncidents = const [],
    this.zones = const [],
    this.selectedZoneId,
    this.selectedFilter = 'ALL',
    this.isLoading = false,
    this.error,
  });

  IncidentState copyWith({
    List<IncidentModel>? activeIncidents,
    List<GridZoneModel>? zones,
    String? selectedZoneId,
    String? selectedFilter,
    bool? isLoading,
    String? error,
  }) {
    return IncidentState(
      activeIncidents: activeIncidents ?? this.activeIncidents,
      zones: zones ?? this.zones,
      selectedZoneId: selectedZoneId ?? this.selectedZoneId,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Returns filtered list of incidents according to selectedFilter.
  List<IncidentModel> get filteredIncidents {
    if (selectedFilter == 'ALL') return activeIncidents;
    return activeIncidents.where((inc) => inc.type.toUpperCase() == selectedFilter.toUpperCase()).toList();
  }
}

/// Notifier managing grid incidents and map zone overlay state.
class IncidentNotifier extends StateNotifier<IncidentState> {
  IncidentNotifier() : super(const IncidentState());

  void setIncidents(List<IncidentModel> incidents) {
    state = state.copyWith(
      activeIncidents: incidents,
      isLoading: false,
    );
  }

  void setZones(List<GridZoneModel> zones) {
    state = state.copyWith(
      zones: zones,
      isLoading: false,
    );
  }

  void selectZone(String? zoneId) {
    state = state.copyWith(selectedZoneId: zoneId);
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void addIncident(IncidentModel incident) {
    final updated = List<IncidentModel>.from(state.activeIncidents)..add(incident);
    state = state.copyWith(activeIncidents: updated);
  }

  void updateIncident(IncidentModel updatedIncident) {
    final updatedList = state.activeIncidents.map((inc) {
      return inc.incidentId == updatedIncident.incidentId ? updatedIncident : inc;
    }).toList();
    state = state.copyWith(activeIncidents: updatedList);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

/// Riverpod provider for Incident and Zone Overlay state management.
final incidentProvider = StateNotifierProvider<IncidentNotifier, IncidentState>((ref) {
  return IncidentNotifier();
});
