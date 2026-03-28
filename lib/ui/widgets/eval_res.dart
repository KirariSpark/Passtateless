import 'package:flutter/material.dart';
import 'package:zxcvbn/zxcvbn.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/styles.dart' as styles;

// 评分 - 文本
const Map<int, String> scoreTextMap = {
  0: "这么弱？",
  1: "有点弱",
  2: "中等",
  3: "有点强",
  4: "！？强强？！"
};


class EvalRes extends StatelessWidget {
  final Result? evalRes;

  /// 用于展示 zxcvbn 的评估结果
  ///
  /// [evalRes] zxcvbn 的评估结果数据
  const EvalRes({
    super.key,
    this.evalRes
  });

  @override
  Widget build(BuildContext context) {
    // 不为空时
    if (evalRes != null) {
      // 处理建议
      String getSuggestionStr() {
        // 为空，或为空列表
        if (evalRes!.feedback.suggestions == null || evalRes!.feedback.suggestions!.join("") == "") {
          return "没有建议";
        } else {
          return evalRes!.feedback.suggestions!.join("");
        }
      }
      return Column(
        spacing: styles.layoutSpacing,
        children: <Widget>[
          // 评分
          styled.buildListTile(
            title: "评分",
            subtitle: (evalRes!.score! + 1).toString(),
            context: context,
            trailing: Text(
              scoreTextMap[evalRes!.score]!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            alpha: styles.alphaSemitransparent
          ),
          // guesses
          styled.buildListTile(
            title: "预估猜测次数",
            subtitle: evalRes!.guesses.toString(),
            context: context,
            alpha: styles.alphaSemitransparent
          ),
          // 警告
          styled.buildListTile(
            title: "警告",
            subtitle: evalRes!.feedback.warning == "" ? "没有警告" : evalRes!.feedback.warning ?? "",
            context: context,
            alpha: styles.alphaSemitransparent
          ),
          // 建议
          styled.buildListTile(
            title: "建议",
            context: context,
            subtitle: getSuggestionStr(),
            alpha: styles.alphaSemitransparent
          ),
        ],
      );
    } else {
      return Column(
        spacing: styles.layoutSpacing,
        children: <Widget>[
          styled.buildListTile(
            title: "请输入评估对象",
            subtitle: "输入要评估的密码，以获取评分、警告和建议",
            context: context,
            alpha: styles.alphaSemitransparent
          )
        ],
      );
    }
  }
}