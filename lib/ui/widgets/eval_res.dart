import 'package:flutter/material.dart';
import 'package:zxcvbn/zxcvbn.dart';
import 'package:passtateless/ui/widgets/styled_list_tile.dart';

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
  const EvalRes({super.key, this.evalRes});

  String _getSuggestion() {
    // feedback为空或为空列表
    if (evalRes!.feedback.suggestions == null || evalRes!.feedback.suggestions!.join("") == "") {
      return "没有建议";
    }
    return evalRes!.feedback.suggestions!.join("");
  }

  String _getWarning() {
    return evalRes!.feedback.warning == "" ? "没有警告" : evalRes!.feedback.warning ?? "";
  }

  @override
  Widget build(BuildContext context) {
    if (evalRes != null) {
      return Column(
        children: <Widget>[
          StyledListTileSimple(
            title: "评分",
            subtitle: (evalRes!.score! + 1).toString(),
            trailing: Text(
              scoreTextMap[evalRes!.score]!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            isFirst: true,
          ),
          StyledListTileSimple(
            title: "预估猜测次数",
            subtitle: evalRes!.guesses.toString(),
          ),
          StyledListTileSimple(
            title: "警告",
            subtitle: _getWarning(),
          ),
          StyledListTileSimple(
            title: "建议",
            subtitle: _getSuggestion(),
            isLast: true,
          ),
        ],
      );
    }
    return StyledListTileSimple(
      title: "请输入密码",
      subtitle: "输入要评估的密码，以获取评分、警告和建议",
      isLast: true,
      isFirst: true,
    );
  }
}