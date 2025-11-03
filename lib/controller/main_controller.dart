

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';


enum DataState { loading, loaded, noData, error }

enum HealthConnectStatus { checking, installed, notInstalled }

enum PermissionStatus { unknown, granted, denied }

class MainController extends ChangeNotifier {
  final Health _health = Health();

  HealthConnectStatus _healthStatus = HealthConnectStatus.checking;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;
  DataState _dataState = DataState.loading;
  List<HealthDataPoint> _sleepSessions = [];

  HealthConnectStatus get healthStatus => _healthStatus;

  PermissionStatus get permissionStatus => _permissionStatus;

  DataState get dataState => _dataState;

  List<HealthDataPoint> get sleepSessions => _sleepSessions;

  final List<HealthDataType> _types = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_SESSION,
  ];
  final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  MainController() {
    initializeApp();
  }

  Future<void> initializeApp() async {
    _healthStatus = HealthConnectStatus.checking;
    notifyListeners();

    try {
      await checkHealthConnectStatus();

      if (_healthStatus == HealthConnectStatus.installed) {

        await checkPermissions();
        if (_permissionStatus == PermissionStatus.granted) {

          await fetchSleepData();
        } else {
          debugPrint("initializeApp: Chưa có quyền.");
        }
      } else {
        debugPrint("initializeApp: Health Connect CHƯA cài.");
      }
    } catch (e) {
      debugPrint(
        "LỖI initializeApp: $e",
      );
      _healthStatus = HealthConnectStatus.notInstalled;
      notifyListeners();
    }
  }

  Future<void> checkHealthConnectStatus() async {
    _healthStatus = HealthConnectStatus.checking;
    notifyListeners();

    final status = await _health.getHealthConnectSdkStatus();
    _healthStatus = (status == HealthConnectSdkStatus.sdkAvailable)
        ? HealthConnectStatus.installed
        : HealthConnectStatus.notInstalled;
    notifyListeners();
  }

  Future<void> installHealthConnect() async {
    try {
      await _health.installHealthConnect();
    } catch (e) {
      debugPrint("Error installing Health Connect: $e");
    }
  }

  Future<void> checkPermissions() async {
    final bool granted =
        await _health.hasPermissions(_types, permissions: _permissions) ??
            false;
    _permissionStatus = granted
        ? PermissionStatus.granted
        : PermissionStatus.denied;
    notifyListeners();
  }

  Future<void> requestPermissions() async {
    final bool granted = await _health.requestAuthorization(
      _types,
      permissions: _permissions,
    );

    _permissionStatus = granted
        ? PermissionStatus.granted
        : PermissionStatus.denied;

    if (_permissionStatus == PermissionStatus.granted) {
      await fetchSleepData();
    }
    notifyListeners();
  }

  Future<void> fetchSleepData() async {
    if (_permissionStatus != PermissionStatus.granted) {
      _dataState = DataState.error;
      notifyListeners();
      return;
    }

    _dataState = DataState.loading;
    notifyListeners();

    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      _sleepSessions.clear();

      _sleepSessions = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: sevenDaysAgo,
        endTime: now,
      );

      _sleepSessions = _health.removeDuplicates(_sleepSessions);
      debugPrint('Total number of data points: ${_sleepSessions.length}. '
          '${_sleepSessions.length > 100 ? 'Only showing the first 100.' : ''}');

      // sort the data points by date
      _sleepSessions.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      for (var data in _sleepSessions) {
        debugPrint(data.toJson().toString());
      }

      if (_sleepSessions.isEmpty) {
        _dataState = DataState.noData;
      } else {
        _dataState = DataState.loaded;
      }
    } catch (e) {
      debugPrint("Error fetching sleep data: $e");
      _dataState = DataState.error;
    } finally {
      notifyListeners();
    }
  }
}
