import 'package:flutter/material.dart';

enum ReportReason { impreciso, noEsPropiedad, estafa, ofensivo, otraMotivo }

class ReportViewModel extends ChangeNotifier {
  ReportReason? _selectedReason;
  String _details = '';

  ReportReason? get selectedReason => _selectedReason;
  String get details => _details;
  bool get canProceed => _selectedReason != null;

  String get reasonLabel => switch (_selectedReason) {
    ReportReason.impreciso => 'Es impreciso o incorrecto',
    ReportReason.noEsPropiedad => 'No es una propiedad real',
    ReportReason.estafa => 'Es una estafa',
    ReportReason.ofensivo => 'Es ofensivo',
    ReportReason.otraMotivo => 'Es por otra motivo',
    null => '',
  };

  void selectReason(ReportReason reason) {
    _selectedReason = reason;
    notifyListeners();
  }

  void setDetails(String value) {
    _details = value;
    notifyListeners();
  }
}