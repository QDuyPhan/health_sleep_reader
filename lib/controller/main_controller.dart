import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

enum DataState { loading, loaded, noData, error }

enum HealthConnectStatus { checking, installed, notInstalled }

enum PermissionStatus { unknown, granted, denied }

class MainController extends ChangeNotifier {
  // Khởi tạo HealthFactory
  final Health _health = Health();

  // Các biến trạng thái
  HealthConnectStatus _healthStatus = HealthConnectStatus.checking;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;
  DataState _dataState = DataState.loading;
  List<HealthDataPoint> _sleepSessions = [];

  // Getters cho UI
  HealthConnectStatus get healthStatus => _healthStatus;

  PermissionStatus get permissionStatus => _permissionStatus;

  DataState get dataState => _dataState;

  List<HealthDataPoint> get sleepSessions => _sleepSessions;

  // Các loại dữ liệu cần truy cập
  final List<HealthDataType> _types = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_SESSION,
  ];
  final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  MainController() {
    // Bắt đầu kiểm tra ngay khi provider được tạo
    initializeApp();
  }

  Future<void> initializeApp() async {
    _healthStatus = HealthConnectStatus.checking;
    notifyListeners();

    try {
      debugPrint("initializeApp: Bắt đầu");
      await checkHealthConnectStatus(); // Sẽ print từ hàm dưới

      if (_healthStatus == HealthConnectStatus.installed) {
        debugPrint(
          "initializeApp: Health Connect đã cài. Đang kiểm tra quyền...",
        );
        await checkPermissions(); // Sẽ print từ hàm dưới
        if (_permissionStatus == PermissionStatus.granted) {
          debugPrint("initializeApp: Đã có quyền. Đang tải dữ liệu...");
          await fetchSleepData();
        } else {
          debugPrint("initializeApp: Chưa có quyền.");
        }
      } else {
        debugPrint("initializeApp: Health Connect CHƯA cài.");
      }
    } catch (e) {
      debugPrint(
        "LỖI NGHIÊM TRỌNG trong initializeApp: $e",
      ); // <-- RẤT QUAN TRỌNG
      _healthStatus = HealthConnectStatus.notInstalled;
      notifyListeners();
    }
  }

  // Yêu cầu A: Kiểm tra trạng thái Health Connect
  Future<void> checkHealthConnectStatus() async {
    _healthStatus = HealthConnectStatus.checking;
    notifyListeners();

    final status = await _health.getHealthConnectSdkStatus();
    _healthStatus = (status == HealthConnectSdkStatus.sdkAvailable)
        ? HealthConnectStatus.installed
        : HealthConnectStatus.notInstalled;
    notifyListeners();
  }

  // Yêu cầu A: Mở link cài đặt Health Connect
  Future<void> installHealthConnect() async {
    // <-- THAY ĐỔI: Dùng phương thức tích hợp sẵn
    try {
      await _health.installHealthConnect();
    } catch (e) {
      debugPrint("Error installing Health Connect: $e");
    }
  }

  // Kiểm tra quyền (ẩn)
  Future<void> checkPermissions() async {
    // <-- THAY ĐỔI: `hasPermissions` vẫn cần `permissions`
    final bool granted =
        await _health.hasPermissions(_types, permissions: _permissions) ??
            false;
    _permissionStatus = granted
        ? PermissionStatus.granted
        : PermissionStatus.unknown;
    notifyListeners();
  }

  // Yêu cầu B: Yêu cầu quyền truy cập
  Future<void> requestPermissions() async {
    // requestAuthorization chỉ cần danh sách types
    final bool granted = await _health.requestAuthorization(
      _types,
      permissions: _permissions,
    );

    print("Health authorization result: $granted");
    _permissionStatus = granted
        ? PermissionStatus.granted
        : PermissionStatus.denied;

    if (_permissionStatus == PermissionStatus.granted) {
      await fetchSleepData();
    }
    notifyListeners(); // Vẫn giữ notify ở đây để UI cập nhật
  }

  // Yêu cầu C: Đọc và hiển thị dữ liệu giấc ngủ
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
      _sleepSessions.map((e) => print(e.toString()));

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
