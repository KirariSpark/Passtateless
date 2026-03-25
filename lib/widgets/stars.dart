import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/widgets/uni_styles.dart' as styles;
import 'package:passtateless/modules/providers/pwd_provider.dart' as pwd_provider;

class StarredPasswords extends StatelessWidget {
  const StarredPasswords({super.key});

  @override
  Widget build(BuildContext context) {
    final starredPasswords = context.watch<pwd_provider.PwdProvider>().starredPwds;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorScheme.of(context).onPrimaryContainer
        ),
        borderRadius: styles.uniBorderRadius
      ),
      child: Padding(
        padding: styles.uniInsetsSmall,
        child: Column(
          children: _buildList(context, starredPasswords),
        ),
      ),
    );
  }

  // 构建列表，传入 context 和数据
  List<ListTile> _buildList(BuildContext context, List<Map<String, dynamic>> starredPasswords) {
    if (starredPasswords.isEmpty) {
      return <ListTile>[
        ListTile(
          shape: styles.uniRoundedBorder,
          onTap: (){},
          leading: const Icon(Icons.not_interested),
          title: const Text("没有收藏"),
          subtitle: const Text("前往管理页面添加收藏项，以在此处快速访问"),
        )
      ];
    } else {
      return <ListTile>[
        for (final (index, item) in starredPasswords.indexed) ListTile(
          shape: styles.uniRoundedBorder,
          onTap: (){},
          leading: Text('${index + 1}', style: Theme.of(context).textTheme.titleLarge),
          title: Text(item['identifier'] ?? '未命名'),
          subtitle: Text(utils.getPresetText(item['preset'])),
        ),
      ];
    }
  }
}
