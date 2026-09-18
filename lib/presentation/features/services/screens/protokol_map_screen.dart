import 'dart:async';
import 'dart:math' as math;

import 'package:Vatandoshlar/presentation/widgets/custom_icon_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:yandex_maps_mapkit_lite/image.dart' as yandex_image;
import 'package:yandex_maps_mapkit_lite/mapkit.dart'
    hide Icon, Image, LocationSettings, Map, TextStyle, Uri;
import 'package:yandex_maps_mapkit_lite/mapkit_factory.dart';
import 'package:yandex_maps_mapkit_lite/src/mapkit/map/camera_listener.dart';
import 'package:yandex_maps_mapkit_lite/src/mapkit/map/camera_update_reason.dart';
import 'package:yandex_maps_mapkit_lite/src/mapkit/map/map.dart' as yandex_map;
import 'package:yandex_maps_mapkit_lite/yandex_map.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/services/protokol_provider.dart';
import '../../home/viewmodels/home_viewmodel.dart';

enum _RequestState { idle, searching, found }

class ProtokolMapScreen extends StatefulWidget {
  const ProtokolMapScreen({super.key});

  @override
  State<ProtokolMapScreen> createState() => _ProtokolMapScreenState();
}

class _ProtokolMapScreenState extends State<ProtokolMapScreen> {
  static const _defaultPoint = Point(latitude: 41.3275, longitude: 69.2812);
  static const _requestDurationSeconds = 3 * 60;

  MapWindow? _mapWindow;
  UserLocationLayer? _userLocationLayer;
  CircleMapObject? _searchArea;
  final _cameraListener = _PickerCameraListener();
  Point _selectedPoint = _defaultPoint;
  Point? _currentPoint;
  Timer? _timer;
  _RequestState _state = _RequestState.idle;
  int _remainingSeconds = _requestDurationSeconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCurrentLocation();
      final vm = context.read<HomeViewModel>();
      if (vm.protokolProviders.isEmpty) await vm.loadProtokolProviders();
      if (mounted) _addMarkers();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _created(MapWindow window) {
    _mapWindow = window;
    window.map.addCameraListener(_cameraListener..onChanged = _onCameraChanged);
    _userLocationLayer = mapkit.createUserLocationLayer(window)
      ..setDefaultSource()
      ..setVisible(true);
    window.map.move(
      CameraPosition(
        _currentPoint ?? _selectedPoint,
        zoom: 12.2,
        azimuth: 0,
        tilt: 0,
      ),
    );
    _addMarkers();
  }

  Future<void> _loadCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    _userLocationLayer
      ?..setDefaultSource()
      ..setVisible(true);
    try {
      final location = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      _currentPoint = Point(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      _selectedPoint = _currentPoint!;
      _mapWindow?.map.move(
        CameraPosition(_currentPoint!, zoom: 14, azimuth: 0, tilt: 0),
      );
    } catch (_) {
      // The map remains usable with the default Tashkent location.
    }
  }

  void _onCameraChanged(CameraPosition position, bool finished) {
    if (finished) _selectedPoint = position.target;
  }

  void _addMarkers() {
    final window = _mapWindow;
    if (window == null || !mounted) return;
    final providers = context.read<HomeViewModel>().protokolProviders;
    final objects = window.map.mapObjects..clear();
    _searchArea = null;
    final icon = yandex_image.ImageProvider.fromImageProvider(
      const AssetImage('assets/images/logo_icon.png'),
    );
    for (final provider in providers) {
      final marker = objects.addPlacemark()
        ..geometry = Point(
          latitude: provider.latitude,
          longitude: provider.longitude,
        );
      marker.setIconWithStyle(
        icon,
        const IconStyle(scale: 0.2, anchor: math.Point(0.5, 1.0)),
      );
    }
    if (_state == _RequestState.searching) {
      _searchArea = objects.addCircle(Circle(_selectedPoint, radius: 3000))
        ..fillColor = AppTheme.color_26287FF0
        ..strokeColor = AppTheme.color_FF287FF0
        ..strokeWidth = 1.5;
    }
  }

  void _call() {
    if (_state != _RequestState.idle) return;
    setState(() {
      _state = _RequestState.searching;
      _remainingSeconds = _requestDurationSeconds;
    });
    _userLocationLayer?.setVisible(false);
    final map = _mapWindow?.map;
    if (map != null) {
      final window = _mapWindow!;
      final mapBottomInset = 270.0;
      window.focusPoint = ScreenPoint(
        x: window.width() / 2,
        y: (window.height() - mapBottomInset) / 2,
      );
      final camera = map.cameraPosition;
      map.move(
        CameraPosition(
          camera.target,
          zoom: math.max(11.5, camera.zoom - 1.2).toDouble(),
          azimuth: camera.azimuth,
          tilt: camera.tilt,
        ),
      );
    }
    _addMarkers();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds = math.max(0, _remainingSeconds - 1);
      });
      if (_remainingSeconds == 0) {
        timer.cancel();
        _userLocationLayer?.setVisible(true);
        setState(() => _state = _RequestState.found);
      }
    });
  }

  void _cancel() {
    _timer?.cancel();
    setState(() {
      _state = _RequestState.idle;
      _remainingSeconds = _requestDurationSeconds;
    });
    _mapWindow?.focusPoint = null;
    _userLocationLayer?.setVisible(true);
    _addMarkers();
  }

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<HomeViewModel>().protokolProviders;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AppConfig.yandexMapKitApiKey.isEmpty
                ? const ColoredBox(color: AppTheme.color_FFE6EAEE)
                : YandexMap(
                    key: const ValueKey('protokol-map'),
                    onMapCreated: _created,
                  ),
          ),
          if (_state == _RequestState.idle || _state == _RequestState.searching)
            Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.paddingOf(context).top + 88,
              bottom: 270,
              child: IgnorePointer(
                child: Center(
                  child: _state == _RequestState.searching
                      ? const _SearchCenterPicker()
                      : const _CenterPicker(),
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 10,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MapButton(
                  icon: Icons.chevron_left,
                  onTap: () => Navigator.maybePop(context),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRouter.protokolProviders,
                    arguments: 'Yevro pratakol',
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.surface,
                    foregroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(context.tr('all_organizations')),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _RequestCard(
              state: _state,
              remainingSeconds: _remainingSeconds,
              providers: providers,
              onCall: _call,
              onCancel: () => _confirmCancel(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierColor: AppTheme.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppTheme.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 11, 10, 10),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Navigator.pop(dialogContext),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.color_FFF3F3F5,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: AppTheme.color_FF475569),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              CustomIconDesign(
                icon: 'assets/icons/failed.svg',
                mainColor: AppTheme.color_FFCE040E,
                secondaryColor: AppTheme.color_FFFF666D,
                padding: 15,
              ),
              const SizedBox(height: 14),
              Text(
                context.tr('cancel_confirmation'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.color_FF1D1816,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('cancel_call_question'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppTheme.color_FF5B4F4B),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: AppTheme.transparent,
                      child: Ink(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.color_FFF1F1F3,
                          borderRadius: BorderRadius.circular(44),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.pop(dialogContext),
                          borderRadius: BorderRadius.circular(44),
                          child: Center(
                            child: Text(
                              context.tr('back'),
                              style: TextStyle(
                                color: AppTheme.color_FF111827,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Material(
                      color: AppTheme.transparent,
                      child: Ink(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.color_FFFB2C36,
                          borderRadius: BorderRadius.circular(44),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _cancel();
                          },
                          borderRadius: BorderRadius.circular(44),
                          child: Center(
                            child: Text(
                              context.tr('cancel'),
                              style: TextStyle(
                                color: AppTheme.surface,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerCameraListener implements MapCameraListener {
  void Function(CameraPosition position, bool finished)? onChanged;

  @override
  void onCameraPositionChanged(
    yandex_map.Map map,
    CameraPosition cameraPosition,
    CameraUpdateReason cameraUpdateReason,
    bool finished,
  ) {
    onChanged?.call(cameraPosition, finished);
  }
}

class _CenterPicker extends StatelessWidget {
  const _CenterPicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.color_FF287FF0,
            borderRadius: BorderRadius.circular(13),
            boxShadow: const [
              BoxShadow(color: AppTheme.color_33000000, blurRadius: 8),
            ],
          ),
          child: const Icon(
            Icons.location_on_outlined,
            color: AppTheme.surface,
            size: 32,
          ),
        ),
        Container(
          width: 4,
          height: 26,
          decoration: BoxDecoration(
            color: AppTheme.color_FF287FF0,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _SearchCenterPicker extends StatelessWidget {
  const _SearchCenterPicker();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/circle_location.svg',
      width: 28,
      height: 28,
    );
  }
}

class _RequestCard extends StatelessWidget {
  final _RequestState state;
  final int remainingSeconds;
  final List<ProtokolProvider> providers;
  final VoidCallback onCall;
  final VoidCallback onCancel;

  const _RequestCard({
    required this.state,
    required this.remainingSeconds,
    required this.providers,
    required this.onCall,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final active = state != _RequestState.idle;
    final found = state == _RequestState.found;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final time =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final progress =
        (1 - remainingSeconds / _ProtokolMapScreenState._requestDurationSeconds)
            .clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SvgPicture.asset('assets/icons/circle_location.svg'),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Tashkent, sh',
                  style: TextStyle(color: AppTheme.color_FF334155, fontSize: 16),
                ),
              ),
              if (!active) ...[
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(21),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.pageBackground,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          child: SvgPicture.asset('assets/icons/edit.svg'),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('change'),
                          style: TextStyle(
                            color: AppTheme.color_FF334155,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          Container(
            height: 1,
            margin: EdgeInsets.only(top: 8, bottom: 16),
            color: AppTheme.textChoco.withValues(alpha: 0.2),
          ),

          if (active && !found) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('waiting_for_response'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.color_FF0F172A,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.color_FF334155,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (!found)
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(16),
                backgroundColor: AppTheme.color_FFE2E8F0,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryBlue,
                ),
              ),
            const SizedBox(height: 16),
          ],
          if (!found) ...[_Summary(count: providers.length)],
          if (found) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.color_FFF8FAFC,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.color_FFE2E8F0),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: AppTheme.color_FFF1F5F9,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset('assets/icons/car.svg'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('arrival_estimate'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '1.2 km',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.color_FF1E293B,
                              ),
                            ),
                            Text(
                              context.tr('distance'),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.color_FF475569,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ProviderPreview(
              provider: providers.isEmpty ? null : providers.first,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Material(
              color: AppTheme.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  color: active ? AppTheme.color_FFFEF2F2 : AppTheme.color_FF287FF0,
                  borderRadius: BorderRadius.circular(44),
                ),
                child: InkWell(
                  onTap: active ? onCancel : onCall,
                  borderRadius: BorderRadius.circular(44),
                  child: Center(
                    child: Text(
                      active ? context.tr('cancel') : context.tr('call'),
                      style: TextStyle(
                        color: active ? AppTheme.danger : AppTheme.surface,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final int count;

  const _Summary({required this.count});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),

    decoration: BoxDecoration(
      color: AppTheme.color_FFF8FAFC,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.color_FFE2E8F0),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.color_FFF1F5F9,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset('assets/icons/lawyer.svg'),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count ${context.tr('found_nearby')}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              context.tr('near_your_location'),
              style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ProviderPreview extends StatelessWidget {
  final ProtokolProvider? provider;

  const _ProviderPreview({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider == null) return const _Summary(count: 0);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.color_FFF8FAFC,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.color_FFE2E8F0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: AppTheme.avatarBackground,
            child: ClipOval(
              child: Image.network(
                '${provider?.imageUrl}',
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 42,
                  height: 42,
                  color: AppTheme.avatarBackground,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/default_user.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Row(
                  spacing: 4,
                  children: [
                    SvgPicture.asset('assets/icons/star.svg'),
                    Text(
                      '${provider!.rating}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.color_FF334155,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: AppTheme.surface,
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 20)),
    ),
  );
}
