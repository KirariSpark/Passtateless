import 'package:flutter/material.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/styles.dart' as styles;

class LogViewPage extends StatelessWidget {
  final String log;
  const LogViewPage({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: styled.buildAppBar(title: "查看日志", context: context, titleTag: "log_view"),
      body: Padding(
        padding: styles.pagePadding,
        child: SingleChildScrollView(child: Text(log, style: TextStyle(fontFamily: "SourceCodePro"))),
      ),
    );
  }
}