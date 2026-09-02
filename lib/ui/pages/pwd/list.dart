import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/edit.dart';
import 'package:passtateless/ui/pages/pwd/view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/pwd_tile.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

/// 查看资料夹中所有密码的页面
///
/// 资料夹名称将会被用于 Hero 动画
class PwdListPage extends StatelessWidget {
  final String folder;

  /// 是否使用 Hero 动画
  final bool useHero;

  /// 页面是否有横向内边距
  final bool hasPadding;

  /// 页面是否有AppBar
  final bool hasAppBar;

  const PwdListPage({
    super.key,
    this.folder = "",
    required this.useHero,
    this.hasPadding = true,
    this.hasAppBar = true
  });

  Future<void> _save(BuildContext context, PwdProvider pwdProvider, AppProvider appProvider) async {
    appLogger.logger.i("Saving changes in password archive");
    ui.showSnackBarQuick("正在保存", context);
    final stat = await pwdProvider.saveArchive(appProvider.masterPwd);
    if (context.mounted) {
      if (stat == ErrorCode.success) {
        appProvider.hasUnsavedChanges = false;
        appLogger.logger.i("Saved successfully");
        ui.showSnackBarQuick("你的档案已保存", context);
      } else {
        appLogger.logger.i("Can not save archive: ${stat.code}");
        ui.showSnackBarQuick(stat.generic, context);
      }
    }
  }

  void _newArchive({
    required BuildContext context, 
    required PwdProvider pwdProvider,
    required AppProvider appProvider  
  }) {
    appLogger.logger.i("Adding empty record to folder $folder");
    final newId = pwdProvider.addEmptyRecordTo(folder);
    appProvider.hasUnsavedChanges = true;
    appLogger.logger.i("Record added, pushing to edit page for new record $newId");
    Navigator.push(
      context, ui.switchRoute(appProvider.currentNavMode, builder: (context) => PwdEditPage(id: newId))
    );
  }

  List<Widget> _buildList({
    required List<Map<String, dynamic>> pwdList,
    required BuildContext context,
    required PwdProvider pwdProvider,
    required AppProvider appProvider,
  }) {
    if (pwdList.isEmpty) {
      return <Widget>[
        ConstrainedBox(
          constraints: styles.tileWidthConstraint,
          child: styled.buildListTile(
            title: "没有密码",
            subtitle: "点击新增一条密码",
            onTapped: () => _newArchive(context: context, pwdProvider: pwdProvider, appProvider: appProvider),
            leading: Icons.not_interested,
            isFirst: true,
            isLast: true,
            context: context,
          ),
        ),
      ];
    } else {
      List<Widget> children = [];
      for (final (index, item) in pwdList.indexed) {
        children.add(
          PwdTile(
            pwdRecord: item,
            isFirst: index == 0,
            isLast: index == pwdList.length - 1,
            onTapped: () {
              appLogger.logger.i("Pushing to view page for ${item["id"]}");
              Navigator.push(
                context,
                ui.switchRoute(
                  appProvider.currentNavMode, builder: (context) => PwdViewPage(id: item["id"], useHero: true),
                ),
              );
            },
            extraContextMenuItems: [
              styled.buildListTile(
                title: "新建档案",
                leading: Icons.add,
                onTapped: () {
                  Navigator.pop(context);
                  _newArchive(context: context, pwdProvider: pwdProvider, appProvider: appProvider);
                },
                context: context
              ),
              styled.buildListTile(
                title: "保存更改",
                leading: Icons.save_outlined,
                isLast: true,
                onTapped: () {
                  Navigator.pop(context);
                  _save(context, pwdProvider, appProvider);
                },
                context: context
              )
            ],
          ),
        );
      }
      return children;
    }
  }

  AppBar? _buildAppBar({
    required BuildContext context,
    required bool hasAppBar,
    required PwdProvider pwdProvider,
    required AppProvider appProvider
  }) {
    if (hasAppBar) {
      return styled.buildAppBar(
        title: "所有密码",
        context: context,
        actions: [
          styled.buildPopupMenuButton(
            context: context,
            children: [
              styled.buildPopupMenuItem(
                description: "新建档案",
                icon: Icons.add,
                onTap: () => _newArchive(context: context, pwdProvider: pwdProvider, appProvider: appProvider)
              ),
              styled.buildPopupMenuItem(
                description: "保存更改",
                icon: Icons.save_outlined,
                onTap: () => _save(context, pwdProvider, appProvider),
              )
            ],
          ),
        ],
        titleTag: useHero ? folder : null,
      );
    }
    return null;
  }

  Scaffold _buildUi(
    List<Map<String, dynamic>> pwdList,
    BuildContext context, {
    required bool useHero,
    required bool hasPadding,
    required AppProvider appProvider,
    required PwdProvider pwdProvider,
  }) {
    return Scaffold(
      appBar: _buildAppBar(context: context, hasAppBar: hasAppBar, pwdProvider: pwdProvider, appProvider: appProvider),
      body: Container(
        alignment: Alignment.topCenter,
        padding: hasPadding ? styles.pagePaddingAll : EdgeInsets.zero,
        child: Container(
          constraints: styles.tileWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._buildList(
                  pwdList: pwdList,
                  context: context,
                  pwdProvider: pwdProvider,
                  appProvider: appProvider
                ),
                // TODO: 彩蛋
                TextField(
                  decoration: InputDecoration(border: InputBorder.none),
                  style: TextStyle(color: Colors.transparent)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final pwdList = context.watch<PwdProvider>().getPwdList(folder);
    final pwdList = context.watch<PwdProvider>().allPwds;
    final appProvider = context.read<AppProvider>();
    final pwdProvider = context.read<PwdProvider>();
    return _buildUi(
      pwdList,
      context,
      useHero: useHero,
      hasPadding: hasPadding,
      appProvider: appProvider,
      pwdProvider: pwdProvider
    );
  }
}
