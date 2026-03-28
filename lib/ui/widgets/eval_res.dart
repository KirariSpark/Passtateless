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
  final Result evalRes;

  /// 用于展示 zxcvbn 的评估结果
  ///
  /// [evalRes] zxcvbn 的评估结果数据
  const EvalRes({
    super.key,
    required this.evalRes
  });

  String _getSuggestionStr() {
    // 为空，或为空列表
    if (evalRes.feedback.suggestions == null || evalRes.feedback.suggestions!.join("") == "") {
      return "没有建议";
    } else {
      return evalRes.feedback.suggestions!.join("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: styles.layoutSpacing,
      children: [
        // 评分
        styled.buildListTile(
          title: "评分",
          subtitle: (evalRes.score! + 1).toString(),
          context: context,
          trailing: Text(
            scoreTextMap[evalRes.score]!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          alpha: 175
        ),
        // guesses
        styled.buildListTile(
          title: "预估猜测次数",
          subtitle: evalRes.guesses.toString(),
          context: context,
          alpha: 175
        ),
        // 警告
        styled.buildListTile(
          title: "警告",
          subtitle: evalRes.feedback.warning == "" ? "没有警告" : evalRes.feedback.warning ?? "",
          context: context,
          alpha: 175
        ),
        // 建议
        styled.buildListTile(
          title: "建议",
          context: context,
          subtitle: _getSuggestionStr(),
          alpha: 175
        ),
      ],
    );
  }
}