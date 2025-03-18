import 'package:flutter/material.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  DateTime selectedDate = DateTime.now();
  bool showAmbient = true;

  @override
  void initState() {
    super.initState();
    if (DateTime.now().isAfter(DateTime(2024, 6, 17))) {
      selectedDate = DateTime(2024, 6, 17);
    } else {
      selectedDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
      child: Text('Monitoring Page', style: TextStyle(fontSize: 24)),
    
      ),
    );
  }
}