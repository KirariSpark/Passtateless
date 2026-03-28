import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zxcvbn/zxcvbn.dart';
import 'package:passtateless/ui/widgets/uni_styles.dart' as styles;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/config_provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: true);
    final v2Provider = Provider.of<ConfigProvider>(context, listen: true);
    final Map<double, String> scoreTextMap = {
      0: "这么弱？",
      1: "有点弱",
      2: "中等",
      3: "有点强",
      4: "！？强强？！"
    };

    return Center(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            // 上半部分：可滚动的内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: styles.uniInsetsSmall,
                child: Column(
                  children: <Widget>[
                    // 提示
                    Text(
                      "输入一个你能记住的“种子”",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: styles.layoutSpacing),
                    // 输入框
                    ConstrainedBox(
                      constraints: styles.uniBoxConstraints,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "例如，你的账号所在平台的名称",
                          border: OutlineInputBorder(),
                        ),
                        controller: appProvider.inputTextController,
                      ),
                    ),
                    const SizedBox(height: styles.layoutSpacing),
                    // 开关
                    ConstrainedBox(
                      constraints: styles.uniBoxConstraints,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          // 移除特殊字符
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: SwitchListTile(
                              value: appProvider.removeSpChar,
                              onChanged: (value) => appProvider.removeSpChar = value,
                              secondary: const Icon(Icons.star_border),
                              title: const Text("移除特殊字符"),
                              subtitle: const Text("移除密码中的特殊字符"),
                              shape: styles.roundedBorder
                            ),
                          ),
                          // 移除字母
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: SwitchListTile(
                              value: appProvider.removeAlpha,
                              onChanged: (value) => appProvider.removeAlpha = value,
                              secondary: const Icon(Icons.abc_rounded),
                              title: const Text("移除字母"),
                              subtitle: const Text("移除密码中的字母"),
                              shape: styles.roundedBorder,
                            ),
                          ),
                          // 移除数字
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: SwitchListTile(
                              value: appProvider.removeDigits,
                              onChanged: (value) => appProvider.removeDigits = value,
                              secondary: const Icon(Icons.onetwothree_rounded),
                              title: const Text("移除数字"),
                              subtitle: const Text("移除密码中的数字"),
                              shape: styles.roundedBorder,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: styles.layoutSpacing),
                  ],
                ),
              ),
            ),
            // 下半部分：固定在底部的按钮区域
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: styles.uniInsetsSmall,
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: styles.layoutSpacing,
                  runSpacing: styles.layoutSpacing,
                  children: <Widget>[
                    // 查看当前密码
                    IconButton(
                      tooltip: "查看密码",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Text(appProvider.generateRes.$2),
                            shape: styles.roundedBorder,
                            title: const Text("当前密码"),
                            actions: <Widget>[
                              TextButton(
                                style: styles.buttonStyle,
                                onPressed: () => Navigator.pop(context),
                                child: const Text("确定")
                              )
                            ],
                          )
                        );
                      },
                      style: styles.buttonStyle,
                      icon: const Icon(Icons.preview_outlined)
                    ),
                    // 生成密码
                    IconButton(
                      tooltip: "生成密码",
                      onPressed: () {
                        appProvider.genPassword(
                          v2Config: v2Provider.v2ConfigJson.text,
                          master: v2Provider.masterPassword.text
                        );
                        if (appProvider.generateRes.$1 == 1) {
                          ui.showSnackBarQuick(appProvider.generateRes.$2, context);
                        } else {
                          ui.showSnackBarQuick("密码已生成", context);
                        }
                      },
                      style: styles.buttonStyle,
                      icon: Icon(
                        color: Theme.of(context).colorScheme.primary,
                        Icons.play_circle
                      ),
                    ),
                    // 评估密码
                    IconButton(
                      tooltip: "评估密码",
                      onPressed: () {
                        // 生成不成功或没有生成
                        if (appProvider.generateRes.$1 != 0) {
                          ui.showAlertQuick("评估密码", "你需要先进行一次成功的生成", "确定", context);
                        // 生成成功.但生成结果为空
                        } else if (appProvider.generateRes.$2 == "") {
                          ui.showAlertQuick("评估密码", "没有密码", "确定", context);
                        // 生成成功
                        } else {
                          Result eval = Zxcvbn().evaluate(appProvider.generateRes.$2);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              scrollable: true,
                              shape: styles.roundedBorder,
                              title: const Text("评估密码"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 评分
                                    ListTile(
                                      title: const Text("评分"),
                                      subtitle: Text(eval.score.toString()),
                                      trailing: Text(
                                        scoreTextMap[eval.score]!,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      )
                                    ),
                                      // guesses
                                    ListTile(
                                      title: const Text("预估猜测次数"),
                                      subtitle: Text(eval.guesses.toString()),
                                    ),
                                    // 警告
                                    ListTile(
                                      title: const Text("警告"),
                                      subtitle: Text(
                                        eval.feedback.warning == "" ? "没有警告" : eval.feedback.warning ?? ""
                                      ),
                                    ),
                                    // 建议
                                    ListTile(
                                      title: const Text("建议"),
                                      subtitle: Text(
                                        eval.feedback.suggestions?.join("\n") == "" ?
                                        "没有建议" : eval.feedback.suggestions?.join("\n") ?? "没有建议"
                                      ),
                                    )
                                  ],
                                ),
                              actions: [
                                TextButton(
                                  style: styles.buttonStyle,
                                  onPressed: () {Navigator.pop(context);},
                                  child: const Text("确定")
                                )
                              ],
                            )
                          );
                        }
                      },
                      style: styles.buttonStyle,
                      icon: const Icon(Icons.fact_check_outlined)
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
