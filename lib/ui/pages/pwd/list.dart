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
  final bool hasHorizontalPadding;

  const PwdListPage({
    super.key,
    required this.folder,
    required this.useHero,
    this.hasHorizontalPadding = true
  });

  Future<void> _save(BuildContext context, PwdProvider pwdProvider) async {
    appLogger.logger.i("Saving changes in password archive");
    ui.showSnackBarQuick("正在保存", context);
    final stat = await pwdProvider.saveArchive(Provider.of<AppProvider>(context, listen: false).masterPwd);
    if (context.mounted) {
      if (stat == ErrorCode.success) {
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
    appLogger.logger.i("Record added, pushing to edit page for new record $newId");
    Navigator.push(
      context, ui.switchRoute(appProvider.currentNavMode, builder: (context) => PwdEditPage(id: newId))
    );
  }

  List<Widget> _buildList(
    List<Map<String, dynamic>> pwdList,
    BuildContext context,
    AppProvider appProvider,
  ) {
    if (pwdList.isEmpty) {
      return <Widget>[
        ConstrainedBox(
          constraints: styles.tileWidthConstraint,
          child: styled.buildListTile(
            title: "没有密码",
            subtitle: "点击页面右下角的 + 以新增一条密码",
            leading: Icons.not_interested,
            isFirst: true,
            isLast: true,
            context: context,
          ),
        ),
      ];
    } else {
      List<Widget> children = [];
      // 构建列表
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
          ),
        );
      }
      return children;
    }
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
      appBar: styled.buildAppBar(
        title: folder.isEmpty ? '未分类' : folder,
        context: context,
        actions: [
          styled.buildPopupMenuButton(
            context: context,
            children: [
              PopupMenuItem(
                child: Row(
                  spacing: styles.layoutSpacing,
                  children: [Icon(Icons.add), Text("新建档案")],
                ),
                onTap: () => _newArchive(
                  context: context,
                  pwdProvider: pwdProvider,
                  appProvider: appProvider
                ),
              ),
              PopupMenuItem(
                child: Row(
                  spacing: styles.layoutSpacing,
                  children: [Icon(Icons.save_outlined), Text("保存更改")],
                ),
                onTap: () => _save(context, pwdProvider),
              )
            ],
          ),
        ],
        titleTag: useHero ? folder : null,
      ),
      body: Container(
        padding: hasPadding ? styles.pagePaddingAll : EdgeInsets.zero,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 主列表区域
              Column(children: _buildList(pwdList, context, appProvider)),
              styles.spacingSizedBox,
              // TODO: 增加实际功能
              TextField(decoration: InputDecoration(border: InputBorder.none)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pwdList = context.watch<PwdProvider>().getPwdList(folder);
    final appProvider = context.read<AppProvider>();
    final pwdProvider = context.read<PwdProvider>();
    return _buildUi(
      pwdList,
      context,
      useHero: useHero,
      hasPadding: hasHorizontalPadding,
      appProvider: appProvider,
      pwdProvider: pwdProvider
    );
  }
}
