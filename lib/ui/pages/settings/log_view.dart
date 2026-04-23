import 'package:flutter/material.dart';

class LogViewPage extends StatelessWidget {
  final String log;
  const LogViewPage({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("LogViewPage")),
      body: SingleChildScrollView(child: Text(log, style: TextStyle(fontFamily: "SourceCodePro"))),
    );
  }
}