import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/eval.dart';
import 'package:passtateless/ui/pages/pwd/folders.dart';
import 'package:passtateless/ui/pages/pwd/view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/widgets/stars.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  (String, String)? _selectedItem;
  bool _isSaving = false;

  Future<void> _save(PwdProvider pwdProvider, AppProvider appProvider) async {
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

  Widget _buildRightPage((String, String) tag, bool isWide) {
    switch (tag) {
      case ("pages", "folders"):
        // 宽屏状态下无需使用Scaffold，因为不需要AppBar，也不需要额外的Padding
        return PwdFolderPage(key: ValueKey(tag.$2), useHero: !isWide, hasPadding: !isWide, hasAppBar: !isWide);
      case ("pages", "pwdEval"):
        return PwdEvalPage(key: ValueKey(tag.$2), useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
      case ("pwd", String id):
        return PwdViewPage(key: ValueKey(id), id: id, useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
      default:
        return styled.buildPlaceHolder(text: "无效选择", context: context);
    }
  }

  Widget _buildTrailing(bool hasUnsavedChanges, PwdProvider pwdProvider, AppProvider appProvider) {
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
      onPressed: () => _save(pwdProvider, appProvider),
      style: styles.buttonStyle,
      icon: Icon(Icons.save_outlined)
    );
  }

  // 构建单个瓦片
  Widget _buildTile({
    required (String, String) tag,
    required String title,
    required String? titleTag,
    required String subtitle,
    required IconData leading,
    Widget trailing = const Icon(Icons.arrow_forward),
    required bool isFirst,
    required bool isLast,
    required bool isWide,
    required BuildContext context,
    required void Function((String, String)) onTapped,
    required bool Function((String, String)) isSelectedCallback,
  }) {
    final isSelected = isSelectedCallback(tag);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchOutCurve: Curves.easeOutCubic,
      switchInCurve: Curves.easeOutCubic,
      child: ConstrainedBox(
        constraints: styles.tileWidthConstraint,
        key: isSelected ? const ValueKey("selected") : const ValueKey("notSelected"),
        child: styled.buildListTile(
          active: isSelected,
          title: title,
          titleTag: titleTag,
          subtitle: subtitle,
          leading: leading,
          trailing: trailing,
          onTapped: () {
            appLogger.logger.d("Selected tag: $tag");
            setState(() => _selectedItem = tag);
            onTapped(tag);
          },
          isFirst: isFirst,
          isLast: isLast,
          context: context,
        ),
      ),
    );
  }

  // 构建左侧面板
  Widget _buildLeftContent(
    BuildContext context,
    bool isWide,
    void Function((String, String) tag) onItemTapped,
    bool Function((String, String) tag) isSelected,
  ) {
    bool hasUnsavedChanges = context.watch<AppProvider>().hasUnsavedChanges;
    final pwdProvider = context.read<PwdProvider>();
    final appProvider = context.read<AppProvider>();

    return ConstrainedBox(
      constraints: styles.tileWidthConstraint,
      child: Column(
        spacing: styles.layoutSpacing,
        children: [
          // 入口部分
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTile(
                tag: ("pages", "folders"),
                title: "资料夹",
                titleTag: isWide ? null : "folders",
                subtitle: hasUnsavedChanges ? "有未保存的更改" : "查看和修改全部密码资料夹",
                leading: Icons.format_list_bulleted,
                trailing: _buildTrailing(hasUnsavedChanges, pwdProvider, appProvider),
                isFirst: true,
                isLast: false,
                isWide: isWide,
                context: context,
                onTapped: onItemTapped,
                isSelectedCallback: isSelected,
              ),
              _buildTile(
                tag: ("pages", "pwdEval"),
                title: "密码强度",
                titleTag: isWide ? null : "pwdEval",
                subtitle: "评估密码强度，并获取相关建议",
                leading: Icons.checklist,
                isFirst: false,
                isLast: true,
                isWide: isWide,
                context: context,
                onTapped: onItemTapped,
                isSelectedCallback: isSelected,
              ),
            ],
          ),
          // 收藏夹
          Expanded(
            child: StarredPasswords(
              hasConstraint: false,
              isWide: isWide,
              onItemTapped: (id) {
                appLogger.logger.d("Selected password: $id");
                setState(() => _selectedItem = ("pwd", id));
                onItemTapped(("pwd", id));
              },
              selectedId: _selectedItem?.$1 == "pwd" && isWide ? _selectedItem?.$2 : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveView(
      leftPaneBuilder: (context, isWide, onItemTapped, isSelected) {
        return _buildLeftContent(context, isWide, onItemTapped, isSelected);
      },
      navMode: context.read<AppProvider>().currentNavMode,
      pageBuilder: _buildRightPage,
      placeholderText: "未选择项目",
      rightPaneConstraints: styles.tileWidthConstraint,
      padding: styles.pagePaddingAll,
    );
  }
}
