import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/eval.dart';
import 'package:passtateless/ui/pages/pwd/list.dart';
import 'package:passtateless/ui/pages/pwd/view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/widgets/pwd_tile.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSaving = false;
  late final AppProvider appProvider;
  late final PwdProvider pwdProvider;

  @override
  void initState() {
    super.initState();
    appProvider = context.read<AppProvider>();
    pwdProvider = context.read<PwdProvider>();
  }

  Future<void> _save() async {
    appLogger.logger.i("Saving changes in password archive");
    setState(() => _isSaving = true);
    ui.showSnackBarQuick("正在保存", context);
    var stat = await pwdProvider.saveArchive(appProvider.masterPwd);
    if (mounted) {
      if (stat == ErrorCode.success) {
        appProvider.hasUnsavedChanges = false;
        setState(() => _isSaving = false);
        appLogger.logger.i("Saved successfully");
        ui.showSnackBarQuick("你的档案已保存", context);
      } else {
        appLogger.logger.i("Can not save archive: ${stat.code}");
        ui.showSnackBarQuick(stat.generic, context);
      }
    }
  }

  Widget _switchPage((String, String) tag, bool isWide) {
    switch (tag) {
      case ("pages", "pwdList"):
        // 宽屏状态下不需要这些东西，父级页面已经做好了
        return PwdListPage(key: ValueKey(tag.$2), hasPadding: !isWide, hasAppBar: !isWide);
      case ("pages", "pwdEval"):
        return PwdEvalPage(key: ValueKey(tag.$2), useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
      case ("pages", "quickMode"):
       return PwdViewPage(key: ValueKey(tag.$2), enableEdit: true, useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
      case ("pwd", String id):
        return PwdViewPage(key: ValueKey(id), id: id, useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
      default:
        return styled.buildPlaceHolder(text: "无效选择", context: context);
    }
  }

  Widget _buildTrailing(bool hasUnsavedChanges) {
    if (!hasUnsavedChanges) {
      return Icon(Icons.arrow_forward);
    }
    if (_isSaving) {
      return CircularProgressIndicator(
        constraints: BoxConstraints(
          maxHeight: 20, maxWidth: 20, minHeight: 20, minWidth: 20
        ),
      );
    }
    return IconButton(
      onPressed: _save,
      style: styles.buttonStyle,
      icon: Icon(Icons.save_outlined)
    );
  }

  // 构建左侧面板
  Widget _buildLeftContent(
    BuildContext context,
    bool isWide,
    void Function((String, String) tag) navigateTo,
    bool Function((String, String) tag) isSelected,
  ) {
    bool hasUnsavedChanges = context.watch<AppProvider>().hasUnsavedChanges;

    return ConstrainedBox(
      constraints: isWide ? styles.tileWidthConstraintSmall : styles.tileWidthConstraint,
      child: ListView(
        children: [
          ...[for (final (index, item) in pwdProvider.starredPwdList.indexed) PwdTile(
            pwdRecord: item,
            isFirst: index == 0,
            isLast: index == pwdProvider.starredPwdList.length - 1,
            isActive: isSelected(("pwd", item.id)),
            onTapped: () => navigateTo(("pwd", item.id)),
          )],
          ? pwdProvider.starredPwdList.isEmpty ? null : styles.spacingSizedBox,
          styled.buildListTile(
            title: "所有密码",
            subtitle: hasUnsavedChanges ? "有未保存的更改" : "查看和修改所有密码",
            leading: Icons.format_list_bulleted,
            trailing: _buildTrailing(hasUnsavedChanges),
            isFirst: true,
            onTapped: () {
              appLogger.logger.d("Selected: ('pages', 'pwdList')");
              navigateTo(("pages", "pwdList"));
            },
            active: isSelected(("pages", "pwdList")),
            context: context
          ),
          styled.buildListTile(
            title: "密码强度",
            titleTag: HeroTags.pwdEval.tag,
            subtitle: "评估密码强度，获取相关建议",
            leading: Icons.checklist,
            trailing: Icon(Icons.arrow_forward),
            onTapped: () {
              appLogger.logger.d("Selected: ('pages', 'pwdEval')");
              navigateTo(("pages", "pwdEval"));
            },
            active: isSelected(("pages", "pwdEval")),
            context: context
          ),
          styled.buildListTile(
            title: "快速开始",
            subtitle: "不创建资料，直接生成密码",
            leading: Icons.play_circle_outline,
            trailing: Icon(Icons.arrow_forward),
            isLast: true,
            onTapped: () {
              appLogger.logger.d("Selected: ('pages', 'pwdEval')");
              navigateTo(("pages", "quickMode"));
            },
            active: isSelected(("pages", "quickMode")),
            context: context
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveView(
      leftPaneBuilder: _buildLeftContent,
      pageBuilder: _switchPage,
      navMode: context.read<AppProvider>().currentNavMode,
      padding: styles.pagePaddingAll,
      widthThreshold:
          styles.tileWidthConstraintSmall.maxWidth +
          styles.tileWidthConstraint.maxWidth +
          styles.layoutSpacing * 2
    );
  }
}
