import 'package:flutter/material.dart';

/// The Amperly palette as a theme extension.
///
/// These are roles, not swatches: a widget asks for `energy` because it shows
/// energy, never because it wants amber. The light set is the warm paper
/// identity; the dark set keeps the same roles on a green-black ground.
@immutable
class AmpColors extends ThemeExtension<AmpColors> {
  const AmpColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.divider,
    required this.outline,
    required this.ink,
    required this.inkSecondary,
    required this.primary,
    required this.primaryDark,
    required this.primaryTint,
    required this.onPrimary,
    required this.onPrimaryTint,
    required this.energy,
    required this.energyTint,
    required this.onEnergy,
    required this.available,
    required this.availableInk,
    required this.availableTint,
    required this.busy,
    required this.busyTint,
    required this.busyInk,
    required this.error,
    required this.errorTint,
    required this.onError,
    required this.info,
    required this.infoTint,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.skeleton,
    required this.mapPlaceholder,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color divider;
  final Color outline;
  final Color ink;
  final Color inkSecondary;
  final Color primary;
  final Color primaryDark;
  final Color primaryTint;
  final Color onPrimary;
  final Color onPrimaryTint;
  final Color energy;
  final Color energyTint;
  final Color onEnergy;
  final Color available;
  final Color availableInk;
  final Color availableTint;
  final Color busy;
  final Color busyTint;
  final Color busyInk;
  final Color error;
  final Color errorTint;
  final Color onError;
  final Color info;
  final Color infoTint;
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color skeleton;
  final Color mapPlaceholder;

  static const AmpColors light = AmpColors(
    background: Color(0xFFF6F4EE),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFECE8DE),
    divider: Color(0xFFDDD8CB),
    outline: Color(0xFFC4BDAC),
    ink: Color(0xFF16201B),
    inkSecondary: Color(0xFF5B665F),
    primary: Color(0xFF0F5C4D),
    primaryDark: Color(0xFF0B4438),
    primaryTint: Color(0xFFE3EFEA),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryTint: Color(0xFF0B4438),
    energy: Color(0xFFF2A516),
    energyTint: Color(0xFFFDF1D8),
    onEnergy: Color(0xFF16201B),
    available: Color(0xFF2E7D4F),
    availableInk: Color(0xFF24663F),
    availableTint: Color(0xFFE4F2E6),
    busy: Color(0xFFC77700),
    busyTint: Color(0xFFFBEEDA),
    busyInk: Color(0xFF8A5200),
    error: Color(0xFFB3261E),
    errorTint: Color(0xFFFBE7E4),
    onError: Color(0xFFFFFFFF),
    info: Color(0xFF2F5D8A),
    infoTint: Color(0xFFE7EFF7),
    inverseSurface: Color(0xFF16201B),
    onInverseSurface: Color(0xFFF6F4EE),
    skeleton: Color(0xFFECE8DE),
    mapPlaceholder: Color(0xFFE8E3D7),
  );

  static const AmpColors dark = AmpColors(
    background: Color(0xFF151A17),
    surface: Color(0xFF1E2521),
    surfaceVariant: Color(0xFF2A322C),
    divider: Color(0xFF333D36),
    outline: Color(0xFF46524A),
    ink: Color(0xFFE9EFE9),
    inkSecondary: Color(0xFFA9B7AD),
    primary: Color(0xFF6FD0B6),
    primaryDark: Color(0xFF0B4438),
    primaryTint: Color(0xFF22352E),
    onPrimary: Color(0xFF08241D),
    onPrimaryTint: Color(0xFF9FE3CE),
    energy: Color(0xFFF0B65A),
    energyTint: Color(0xFF3A2E17),
    onEnergy: Color(0xFF16201B),
    available: Color(0xFF7FD39A),
    availableInk: Color(0xFF7FD39A),
    availableTint: Color(0xFF1F3326),
    busy: Color(0xFFE8B25F),
    busyTint: Color(0xFF3A2E18),
    busyInk: Color(0xFFE8B25F),
    error: Color(0xFFF0A69C),
    errorTint: Color(0xFF3A2320),
    onError: Color(0xFF2A0F0C),
    info: Color(0xFF9CC3E5),
    infoTint: Color(0xFF1F2C38),
    inverseSurface: Color(0xFFE9EFE9),
    onInverseSurface: Color(0xFF16201B),
    skeleton: Color(0xFF2A322C),
    mapPlaceholder: Color(0xFF232B26),
  );

  @override
  AmpColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? divider,
    Color? outline,
    Color? ink,
    Color? inkSecondary,
    Color? primary,
    Color? primaryDark,
    Color? primaryTint,
    Color? onPrimary,
    Color? onPrimaryTint,
    Color? energy,
    Color? energyTint,
    Color? onEnergy,
    Color? available,
    Color? availableInk,
    Color? availableTint,
    Color? busy,
    Color? busyTint,
    Color? busyInk,
    Color? error,
    Color? errorTint,
    Color? onError,
    Color? info,
    Color? infoTint,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? skeleton,
    Color? mapPlaceholder,
  }) {
    return AmpColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      divider: divider ?? this.divider,
      outline: outline ?? this.outline,
      ink: ink ?? this.ink,
      inkSecondary: inkSecondary ?? this.inkSecondary,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryTint: primaryTint ?? this.primaryTint,
      onPrimary: onPrimary ?? this.onPrimary,
      onPrimaryTint: onPrimaryTint ?? this.onPrimaryTint,
      energy: energy ?? this.energy,
      energyTint: energyTint ?? this.energyTint,
      onEnergy: onEnergy ?? this.onEnergy,
      available: available ?? this.available,
      availableInk: availableInk ?? this.availableInk,
      availableTint: availableTint ?? this.availableTint,
      busy: busy ?? this.busy,
      busyTint: busyTint ?? this.busyTint,
      busyInk: busyInk ?? this.busyInk,
      error: error ?? this.error,
      errorTint: errorTint ?? this.errorTint,
      onError: onError ?? this.onError,
      info: info ?? this.info,
      infoTint: infoTint ?? this.infoTint,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      skeleton: skeleton ?? this.skeleton,
      mapPlaceholder: mapPlaceholder ?? this.mapPlaceholder,
    );
  }

  @override
  AmpColors lerp(covariant AmpColors? other, double t) {
    if (other == null) {
      return this;
    }
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AmpColors(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceVariant: mix(surfaceVariant, other.surfaceVariant),
      divider: mix(divider, other.divider),
      outline: mix(outline, other.outline),
      ink: mix(ink, other.ink),
      inkSecondary: mix(inkSecondary, other.inkSecondary),
      primary: mix(primary, other.primary),
      primaryDark: mix(primaryDark, other.primaryDark),
      primaryTint: mix(primaryTint, other.primaryTint),
      onPrimary: mix(onPrimary, other.onPrimary),
      onPrimaryTint: mix(onPrimaryTint, other.onPrimaryTint),
      energy: mix(energy, other.energy),
      energyTint: mix(energyTint, other.energyTint),
      onEnergy: mix(onEnergy, other.onEnergy),
      available: mix(available, other.available),
      availableInk: mix(availableInk, other.availableInk),
      availableTint: mix(availableTint, other.availableTint),
      busy: mix(busy, other.busy),
      busyTint: mix(busyTint, other.busyTint),
      busyInk: mix(busyInk, other.busyInk),
      error: mix(error, other.error),
      errorTint: mix(errorTint, other.errorTint),
      onError: mix(onError, other.onError),
      info: mix(info, other.info),
      infoTint: mix(infoTint, other.infoTint),
      inverseSurface: mix(inverseSurface, other.inverseSurface),
      onInverseSurface: mix(onInverseSurface, other.onInverseSurface),
      skeleton: mix(skeleton, other.skeleton),
      mapPlaceholder: mix(mapPlaceholder, other.mapPlaceholder),
    );
  }
}

extension AmpColorsContext on BuildContext {
  /// The palette for the current theme. Amperly always installs it.
  AmpColors get amp => Theme.of(this).extension<AmpColors>()!;
}
