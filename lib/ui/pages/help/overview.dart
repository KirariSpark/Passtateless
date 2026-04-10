import 'package:flutter/material.dart';
import 'package:passtateless/ui/pages/help/doc_view.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;

class HelpOverviewPage extends StatelessWidget {
  const HelpOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: styles.pagePaddingAll,
        alignment: AlignmentGeometry.topCenter,
        constraints: styles.pageWidthConstraint,
        child: SingleChildScrollView(
          child: Column(
            spacing: styles.layoutSpacing,
            children: <Widget>[
              styled.buildListTile(
                title: "基础信息",
                titleTag: "basic",
                subtitle: "关于无状态密码管理器和 Passtateless，你需要知道的一切",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DocViewPage(title: "基础信息", mode: "basic"))
                  );
                },
                context: context
              ),
              styled.buildListTile(
                title: "常见问题",
                titleTag: "faq",
                subtitle: "你可能会遇到的问题",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DocViewPage(title: "常见问题", mode: "faq"))
                  );
                },
                context: context
              ),
              styled.buildListTile(
                title: "开始使用",
                titleTag: "get_started",
                subtitle: "第一次使用？查看此文档以快速上手",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DocViewPage(title: "开始使用", mode: "get_started"))
                  );
                },
                context: context
              ),
              styled.buildListTile(
                title: "JSON 基础",
                titleTag: "json",
                subtitle: "了解基础的 JSON 语法，用于编写自定义生成设置",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DocViewPage(title: "JSON 基础", mode: "json"))
                  );
                },
                context: context
              ),
              styled.buildListTile(
                title: "格式化与可读性",
                titleTag: "formatting",
                subtitle: "了解配置编辑器的特性，包括自动格式化、语法高亮等",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => DocViewPage(title: "格式化与可读性", mode: "formatting"))
                  );
                },
                context: context
              ),
              styled.buildListTile(
                title: "生成配置",
                titleTag: "cfg",
                subtitle: "了解如何自定义生成配置，可用功能及其参数",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => DocViewPage(title: "生成配置", mode: "cfg"))
                  );
                },
                context: context
              ),
              styled.buildListTile(
                title: "生成配置提示",
                titleTag: "cfg_tips",
                subtitle: "在配置生成算法时，你应该注意的一些事情",
                trailing: Icon(Icons.arrow_forward),
                onTapped: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => DocViewPage(title: "生成配置提示", mode: "cfg_tips"))
                  );
                },
                context: context
              ),
            ],
          ),
        ),
      ),
    );
  }
}