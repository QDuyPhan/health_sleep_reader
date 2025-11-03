import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controller/main_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late final MainController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = context.read<MainController>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      await controller.checkHealthConnectStatus();
      if (controller.healthStatus == HealthConnectStatus.installed) {
        await controller.checkPermissions();
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Data")),
      body: Consumer<MainController>(
        builder: (context, controller, child) {
          switch (controller.healthStatus) {
            case HealthConnectStatus.checking:
              return _buildLoadingIndicator(
                "Checking Health Connect status...",
              );
            case HealthConnectStatus.notInstalled:
              return _buildNotInstalledView(controller);
            case HealthConnectStatus.installed:
              switch (controller.permissionStatus) {
                case PermissionStatus.unknown:
                  return _buildPermissionRequestView(
                    controller,
                    "Please grant permission to read sleep data.",
                  );
                case PermissionStatus.denied:
                  return _buildPermissionRequestView(
                    controller,
                    "The app cannot display sleep data without permission.",
                  );
                case PermissionStatus.granted:
                  return _buildDataView(controller);
              }
          }
        },
      ),
    );
  }

  Widget _buildNotInstalledView(MainController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "Health Connect is required to sync sleep data. Please install it.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.installHealthConnect,
              child: const Text("Install Health Connect"),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPermissionRequestView(
    MainController controller,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 50, color: Colors.orange),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                controller.requestPermissions();
              },
              child: Text(
                controller.permissionStatus == PermissionStatus.denied
                    ? "Retry Permission"
                    : "Grant Permission",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataView(MainController controller) {
    switch (controller.dataState) {
      case DataState.loading:
        return _buildLoadingIndicator("Fetching sleep data...");
      case DataState.error:
        return const Center(
          child: Text("An error occurred while fetching data."),
        );
      case DataState.noData:
        return const Center(child: Text("No Data"));
      case DataState.loaded:
        return ListView.builder(
          itemCount: controller.sleepSessions.length,
          itemBuilder: (context, index) {
            final session = controller.sleepSessions[index];
            final startTime = session.dateFrom;
            final endTime = session.dateTo;
            final duration = endTime.difference(startTime);
            final hours = duration.inHours;
            final minutes = duration.inMinutes % 60;
            final dateText = DateFormat('EEE, d MMM', 'vi').format(startTime);
            final start = DateFormat('HH:mm').format(startTime);
            final end = DateFormat('HH:mm').format(endTime);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.indigo[50],
                      child: const Icon(Icons.bedtime, color: Colors.indigo, size: 28),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$start – $end",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),

                          const Text(
                            "Ngủ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            "Thời gian ngủ: ${hours}giờ ${minutes}phút",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Text(
                            dateText,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
    }
  }

  Widget _buildLoadingIndicator(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
