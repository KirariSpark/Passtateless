import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/file_mgr/core_mgr.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/settings/log_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/styled_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';

// 高级设置页面
class AdvancedSettingsPage extends StatefulWidget {
  /// 有AppBar时，是否要使用Hero动画
  final bool useHero;

  /// 是否要包含AppBar
  final bool hasAppBar;

  /// 是否有内边距
  final bool hasPadding;

  const AdvancedSettingsPage({
    super.key,
    required this.useHero,
    this.hasAppBar = true,
    this.hasPadding = true
  });

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  final CodeLineEditingController configController = CodeLineEditingController();
  late final AppProvider _appProvider;

  Future<void> _changeLogLvl(LogLevels value) async {
    _appProvider.currentLogLevel = value;
    final stat = await _appProvider.saveConfig();
    if (mounted && stat != ErrorCode.success) ui.showSnackBarQuick(stat.generic, context);
  }

  void _showLogLvlDialog() {
    ui.showAlertDialogQuick(
      title: "日志等级",
      content: RadioGroup(
        groupValue: _appProvider.currentLogLevel,
        onChanged: (value) {
          _changeLogLvl(value!);
          Navigator.of(context).pop();
        },
        child: Column(
          children: [
            for (var item in LogLevels.values) RadioListTile(
              value: item,
              title: Text(item.displayName),
              shape: styles.roundedBorder,
            )
          ],
        )
      ),
      action: () => Navigator.of(context).pop(),
      actionText: "取消",
      context: context
    );
  }

  Future<void> _viewLog() async {
    appLogger.logger.i("Loading log");
    final (stat, res) = await readTextFile(Paths.log.path);
    if (context.mounted && stat == ErrorCode.success) {
      appLogger.logger.i("Log loaded");
      Navigator.push(context, MaterialPageRoute(builder: (_) => LogViewPage(log: res)));
    } else {
      appLogger.logger.e("Can not load log: ${stat.code}");
      ui.showSnackBarQuick(stat.generic, context);
    }
  }

  @override
  void initState() {
    super.initState();
    _appProvider = context.read<AppProvider>();
  }

  @override
  void dispose() {
    configController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hasAppBar
        ? styled.buildAppBar(title: "高级设置", titleTag: widget.useHero ? HeroTags.advancedSettings.tag : null, context: context)
        : null,
      body: Container(
        alignment: Alignment.topLeft,
        padding: widget.hasPadding ? styles.pagePaddingAll : null,
        child: ConstrainedBox(
          constraints: styles.tileWidthConstraint,
          child: ListView(
            children: [
              StyledListTileSimple(
                isFirst: true,
                title: "日志等级",
                trailing: Icon(Icons.arrow_drop_down),
                onTap: _showLogLvlDialog,
              ),
              StyledListTileSimple(
                title: "查看日志",
                trailing: Icon(Icons.arrow_forward),
                isLast: true,
                onTap: _viewLog,
              )
            ],
          ),
        ),
      ),
    );
  }
}