import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/core/pwd_item.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/edit.dart';
import 'package:passtateless/ui/pages/pwd/view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/pwd_tile.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/styled_list_tile.dart';
import 'package:provider/provider.dart';

/// 查看所有密码的页面
class PwdListPage extends StatefulWidget {
  /// 页面是否有横向内边距
  final bool hasPadding;

  /// 页面是否有AppBar
  final bool hasAppBar;

  const PwdListPage({
    super.key,
    this.hasPadding = true,
    this.hasAppBar = true
  });

  @override
  State<PwdListPage> createState() => _PwdListPageState();
}

class _PwdListPageState extends State<PwdListPage> {
  /// 当前选中的、用于过滤密码的标签集合
  final Set<String> _selectedTags = {};

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
    appLogger.logger.i("Adding empty record");
    final newId = pwdProvider.addEmptyRecord();
    appProvider.hasUnsavedChanges = true;
    appLogger.logger.i("Record added, pushing to edit page for new record $newId");
    Navigator.push(
      context, MaterialPageRoute(builder: (context) => PwdEditPage(id: newId))
    );
  }

  List<Widget> _buildList({
    required List<PwdItem> pwdList,
    required BuildContext context,
    required PwdProvider pwdProvider,
    required AppProvider appProvider,
    bool noMatch = false,
  }) {
    if (pwdList.isEmpty) {
      return <Widget>[
        ConstrainedBox(
          constraints: styles.tileWidthConstraint,
          child: StyledListTileSimple(
            title: noMatch ? "没有符合条件的密码" : "没有密码",
            subtitle: noMatch ? "选择其他标签试试" : "点击新增一条密码",
            onTap: () => _newArchive(context: context, pwdProvider: pwdProvider, appProvider: appProvider),
            leadingIcon: Icons.not_interested,
            isFirst: true,
            isLast: true,
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
              appLogger.logger.i("Pushing to view page for ${item.id}");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PwdViewPage(id: item.id, useHero: true)),
              );
            },
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
      );
    }
    return null;
  }

  /// 聚合所有密码记录中出现过的不同标签
  List<String> get _allTags {
    final Set<String> tags = {};
    for (final pwd in context.read<PwdProvider>().pwdList) {
      tags.addAll(pwd.tags);
    }
    return tags.toList();
  }

  /// 顶部固定的标签筛选器
  Widget _buildFilterRow() {
    final List<String> allTags = _allTags;
    final selectedAll = _selectedTags.isEmpty;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: styles.uniInsetsSmall,
      child: Row(
        spacing: styles.layoutSpacing,
        children: [
          FilterChip(
            label: const Text("全部"),
            selected: selectedAll,
            onSelected: (_) => setState(_selectedTags.clear),
          ),
          for (final tag in allTags) FilterChip(
            label: Text(tag),
            selected: _selectedTags.contains(tag),
            onSelected: (selected) => setState(() {
              if (selected) {
                _selectedTags.add(tag);
              } else {
                _selectedTags.remove(tag);
              }
            }),
          ),
        ],
      ),
    );
  }

  Scaffold _buildUi(
    List<PwdItem> pwdList,
    BuildContext context, {
    required bool hasPadding,
    required AppProvider appProvider,
    required PwdProvider pwdProvider,
  }) {
    final bool noMatch =
        _selectedTags.isNotEmpty && pwdList.isEmpty && _allTags.isNotEmpty;
    return Scaffold(
      appBar: _buildAppBar(context: context, hasAppBar: widget.hasAppBar, pwdProvider: pwdProvider, appProvider: appProvider),
      body: Container(
        alignment: Alignment.topCenter,
        padding: hasPadding ? styles.pagePaddingAll : EdgeInsets.zero,
        child: Container(
          constraints: styles.tileWidthConstraint,
          child: Column(
            children: [
              _buildFilterRow(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ..._buildList(
                        pwdList: pwdList,
                        context: context,
                        pwdProvider: pwdProvider,
                        appProvider: appProvider,
                        noMatch: noMatch,
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pwds = context.watch<PwdProvider>().pwdList;
    final appProvider = context.read<AppProvider>();
    final pwdProvider = context.read<PwdProvider>();
    final filtered = _selectedTags.isEmpty
      ? pwds : [for (final pwd in pwds) if (_selectedTags.every(pwd.hasTag)) pwd];
    return _buildUi(
      filtered,
      context,
      hasPadding: widget.hasPadding,
      appProvider: appProvider,
      pwdProvider: pwdProvider
    );
  }
}
