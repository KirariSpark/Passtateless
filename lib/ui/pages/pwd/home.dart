import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
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
  bool _isPwdSelected = false;
  String? _selectedPwdId;
  bool _isSaving = false;
  late final AppProvider _appProvider;
  late final PwdProvider _pwdProvider;

  @override
  void initState() {
    super.initState();
    _appProvider = context.read<AppProvider>();
    _pwdProvider = context.read<PwdProvider>();
  }

  Future<void> _save() async {
    appLogger.logger.i("Saving changes in password archive");
    setState(() => _isSaving = true);
    ui.showSnackBarQuick("正在保存", context);
    var stat = await _pwdProvider.saveArchive(_appProvider.masterPwd);
    if (mounted) {
      if (stat == ErrorCode.success) {
        _appProvider.hasUnsavedChanges = false;
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
      case ("pages", "folders"):
        // 宽屏状态下不需要这些东西，父级页面已经做好了
        return PwdFolderPage(key: ValueKey(tag.$2), useHero: !isWide, hasPadding: !isWide, hasAppBar: !isWide);
      case ("pages", "pwdEval"):
        return PwdEvalPage(key: ValueKey(tag.$2), useHero: !isWide, hasAppBar: !isWide, hasPadding: !isWide);
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
      child: Column(
        spacing: styles.layoutSpacing,
        children: [
          // 入口部分
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              styled.buildListTile(
                title: "资料夹",
                titleTag: HeroTags.folders.tag,
                subtitle: hasUnsavedChanges ? "有未保存的更改" : "查看和修改全部密码资料夹",
                leading: Icons.format_list_bulleted,
                trailing: _buildTrailing(hasUnsavedChanges),
                isFirst: true,
                onTapped: () {
                  setState(() => _isPwdSelected = false);
                  appLogger.logger.d("Selected: ('pages', 'folders')");
                  navigateTo(("pages", "folders"));
                },
                active: isSelected(("pages", "folders")),
                context: context
              ),
              styled.buildListTile(
                title: "密码强度",
                titleTag: HeroTags.pwdEval.tag,
                subtitle: "评估密码强度，获取相关建议",
                leading: Icons.checklist,
                trailing: Icon(Icons.arrow_forward),
                isLast: true,
                onTapped: () {
                  setState(() => _isPwdSelected = false);
                  appLogger.logger.d("Selected: ('pages', 'pwdEval')");
                  navigateTo(("pages", "pwdEval"));
                },
                active: isSelected(("pages", "pwdEval")),
                context: context
              )
            ],
          ),
          // 收藏夹
          Expanded(
            child: StarredPasswords(
              hasConstraint: false,
              isWide: isWide,
              onItemTapped: (id) {
                appLogger.logger.d("Selected password from home page: $id");
                setState(() {
                  _selectedPwdId = id;
                  _isPwdSelected = true;
                });
                navigateTo(("pwd", id));
              },
              selectedId: _isPwdSelected && isWide ? _selectedPwdId : null,
            ),
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
