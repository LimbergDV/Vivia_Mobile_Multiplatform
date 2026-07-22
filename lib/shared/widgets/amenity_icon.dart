import 'package:flutter/material.dart';

IconData amenityIcon(String name) {
  final normalized = _normalize(name);
  for (final entry in _amenityIcons) {
    if (entry.keys.any(normalized.contains)) return entry.icon;
  }
  return Icons.check_circle_outline_rounded;
}

String _normalize(String value) {
  var result = value.toLowerCase();
  const accents = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };
  accents.forEach((from, to) => result = result.replaceAll(from, to));
  return result;
}

const _amenityIcons = <({List<String> keys, IconData icon})>[
  (keys: ['piscina', 'alberca'], icon: Icons.pool_rounded),
  (keys: ['gimnasio', 'gym'], icon: Icons.fitness_center_rounded),
  (keys: ['spa', 'jacuzzi', 'sauna'], icon: Icons.hot_tub_rounded),
  (
    keys: ['estacionamiento', 'cochera', 'garage', 'parking'],
    icon: Icons.local_parking_rounded,
  ),
  (keys: ['porton', 'portico'], icon: Icons.garage_rounded),
  (
    keys: ['seguridad', 'vigilancia', 'camara', 'caseta'],
    icon: Icons.security_rounded,
  ),
  (keys: ['interfono', 'intercomunicador', 'timbre'], icon: Icons.doorbell_rounded),
  (keys: ['wifi', 'internet', 'fibra'], icon: Icons.wifi_rounded),
  (keys: ['tv', 'television', 'cable'], icon: Icons.tv_rounded),
  (
    keys: ['aire', 'clima', 'acondicionado', 'minisplit'],
    icon: Icons.ac_unit_rounded,
  ),
  (
    keys: ['calefaccion', 'calentador', 'boiler', 'caldera'],
    icon: Icons.thermostat_rounded,
  ),
  (keys: ['elevador', 'ascensor'], icon: Icons.elevator_rounded),
  (keys: ['jardin', 'areas verdes', 'cesped'], icon: Icons.yard_rounded),
  (keys: ['terraza', 'balcon'], icon: Icons.balcony_rounded),
  (keys: ['roof', 'azotea', 'deck'], icon: Icons.deck_rounded),
  (
    keys: ['juegos', 'ludico', 'niños', 'infantil', 'parque'],
    icon: Icons.child_friendly_rounded,
  ),
  (keys: ['salon', 'eventos', 'fiestas', 'usos multiples'], icon: Icons.celebration_rounded),
  (
    keys: ['lavanderia', 'lavado', 'lavadora'],
    icon: Icons.local_laundry_service_rounded,
  ),
  (keys: ['amueblado', 'amueblada', 'muebles'], icon: Icons.weekend_rounded),
  (keys: ['mascota', 'pet'], icon: Icons.pets_rounded),
  (keys: ['cisterna', 'agua'], icon: Icons.water_drop_rounded),
  (keys: ['bodega', 'almacen', 'trastero'], icon: Icons.warehouse_rounded),
  (keys: ['asador', 'parrilla', 'bbq', 'quincho'], icon: Icons.outdoor_grill_rounded),
  (keys: ['cocina', 'comedor'], icon: Icons.kitchen_rounded),
  (keys: ['closet', 'vestidor'], icon: Icons.checkroom_rounded),
  (keys: ['solar', 'panel', 'energia'], icon: Icons.solar_power_rounded),
  (keys: ['gas'], icon: Icons.propane_tank_rounded),
  (keys: ['vista', 'panoramica', 'mirador'], icon: Icons.landscape_rounded),
  (keys: ['cancha', 'deportiva', 'padel', 'tenis'], icon: Icons.sports_soccer_rounded),
  (keys: ['accesible', 'rampa', 'discapacidad'], icon: Icons.accessible_rounded),
  (keys: ['recepcion', 'conserje', 'lobby'], icon: Icons.room_service_rounded),
];
