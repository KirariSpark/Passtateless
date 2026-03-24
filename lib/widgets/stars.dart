import 'package:flutter/material.dart';
import 'package:passtateless/widgets/uni_styles.dart' as styles;

class StarredPasswords extends StatefulWidget {
  const StarredPasswords({super.key});

  @override
  State<StarredPasswords> createState() => _StarredPasswordsState();
}

class _StarredPasswordsState extends State<StarredPasswords> {
  List<Map<String, dynamic>> _starredPasswords = [];

  void updatePasswords(List<Map<String, dynamic>> newPasswords) {
    setState(() {
      _starredPasswords = newPasswords;
    });
  }

  // 构建列表
  List<ListTile> _buildList() {
    if (_starredPasswords.isEmpty) {
      return <ListTile>[
        ListTile(
          shape: styles.uniRoundedBorder,
          onTap: (){},
          leading: Icon(Icons.not_interested),
          title: Text("没有收藏"),
          subtitle: Text("前往管理页面添加收藏项，以在此处快速访问"),
        )
      ];
    } else {
      return <ListTile>[
        for (final (index, item) in _starredPasswords.indexed)
          ListTile(
            shape: styles.uniRoundedBorder,
            onTap: (){},
            leading: Text('${index + 1}', style: Theme.of(context).textTheme.titleLarge),
            title: Text(item['identifier'] ?? '未命名'),
            subtitle: Text(_getPresetText(item['preset'])),
          ),
      ];
    }
  }

  // 将 preset 的英文键值映射为中文描述
  String _getPresetText(String? preset) {
    switch (preset) {
      case 'simple':
        return '简单模式';
      case 'complex':
        return '复杂模式';
      case 'bank':
        return '支付密码模式';
      case 'custom':
        return '自定义模式';
      default:
        return '未知模式';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(
          color: ColorScheme.of(context).onPrimaryContainer
        ),
        borderRadius: styles.uniBorderRadius
      ),
      child: Padding(
        padding: styles.uniInsetsSmall,
        child: SingleChildScrollView(
          child: Column(
            children: _buildList(),
          ),
        ),
      ),
    );
  }
}