import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/ui/pages/pwd/edit.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/pwd_tile.dart';
import 'package:provider/provider.dart';

class StarredPasswords extends StatelessWidget {
  /// 当前是否有高度约束
  final bool hasConstraint;
  /// 用于告知当前是否为宽屏，同时会决定是否使用 Hero 动画
  final bool isWide;
  /// 点击回调，发生于内部条目被点击时
  final void Function(String id)? onItemTapped; 
  /// 选中项的UUID，用于高亮选中项
  final String? selectedId;
  /// 密码收藏夹页面
  const StarredPasswords({
    super.key,
    required this.hasConstraint,
    required this.isWide,
    this.onItemTapped,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final starredPasswords = context.watch<PwdProvider>().starredPwds;
    return Container(
      constraints: hasConstraint ? styles.tileHeightConstraint : null,
      decoration: BoxDecoration(
        color: ColorScheme.of(context).surfaceContainerLow,
        borderRadius: styles.borderRadius
      ),
      padding: styles.uniInsetsSmall,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildList(context, starredPasswords, selectedId),
        ),
      ),
    );
  }

  List<Widget> _buildList(
    BuildContext context, 
    List<Map<String, dynamic>> starredPasswords, 
    String? selectedId
  ) {
    if (starredPasswords.isEmpty) {
      return <Widget>[
        ListTile(
          shape: styles.roundedBorder,
          tileColor: ColorScheme.of(context).primaryContainer.withAlpha(styles.alphaSemitransparent),
          title: const Text("没有收藏"),
          subtitle: const Text("前往管理页面添加收藏项，以在此处快速访问"),
        )
      ];
    } else {
      List<Widget> temp = [
        Text("收藏夹", style: Theme.of(context).textTheme.titleLarge),
        styles.spacingSizedBox
      ];
      for (var(index, record) in starredPasswords.indexed) {
        temp.add(
          PwdTile(
            pwdRecord: record,
            onStarPressed: (){
              appLogger.logger.d("Star button of ${record["id"]} pressed");
              Provider.of<PwdProvider>(context, listen: false).switchStarStateById(record["id"]);
            },
            onEditPressed: (){
              appLogger.logger.i("Pushing to edit page for ${record["id"]}");
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEditPage(id: record["id"])));
            },
            onTapped: (){
              // 将点击事件和id传递给父组件
              appLogger.logger.d("Item ${record["id"]} tapped");
              onItemTapped?.call(record["id"]);
            },
            isFirst: index == 0,
            isLast: index == starredPasswords.length - 1,
            isActive: record["id"] == selectedId,
            useHero: !isWide,
          )
        );
      }
      return temp;
    }
  }
}
