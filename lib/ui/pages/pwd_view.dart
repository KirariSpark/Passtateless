import 'package:flutter/material.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/utils/utils.dart' as utils;
import 'package:passtateless/ui/pages/cfg_edit.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:re_editor/re_editor.dart';

class PwdViewPage extends StatefulWidget {
  final String identifier;
  final String userName;
  final String account;
  final bool removeDigits;
  final bool removeAlpha;
  final bool removeSp;

  const PwdViewPage({
    super.key, required this.identifier, required this.userName, required this.account,
    required this.removeDigits, required this.removeAlpha, required this.removeSp
  });

  @override
  State<PwdViewPage> createState() => _PwdViewPageState();
}

class _PwdViewPageState extends State<PwdViewPage> {
  String _preset = "simple";
  final CodeLineEditingController _configController = CodeLineEditingController.fromText("[{\"name\":\"toBase64\"}]");
  final void Function() _onCopyClicked = (){};

  /// 根据当前预设决定是否显示自定义规则
  Widget? _showConfigEdit() {
    if (_preset == "custom") {
      return styled.buildListTile(
        context: context,
        title: "配置生成规则",
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "点击编辑",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Icon(Icons.arrow_forward_ios, size: 16)
          ],
        ),
        alpha: styles.alphaSemitransparent,
        onTapped: () async {
          // 跳转并等待返回结果
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CfgEditPage(
                // 把当前的文本传给新页面
                initialText: _configController.text,
              ),
            ),
          );

          // 如果用户点击了保存(result不为空)，则更新本地的控制器
          if (result != null && result is String) {
            setState(() {
              _configController.text = result;
            });
            // 发送通知
            if (mounted) {
              ui.showSnackBarQuick("编辑结果已保存", context);
            }
          }
        },
      );
    } else {
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_outlined),
          style: styles.buttonStyle,
        ),
        title: Text("查看：${widget.identifier.isEmpty ? '未命名' : widget.identifier}"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: styles.uniInsetsSmall,
          child: Center(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double maxWidth = ui.calcWidthConstraint(constraints.maxWidth, true, maxColumns: 3);
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    spacing: styles.layoutSpacing,
                    children: <Widget>[
                      // 只读部分
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // 档案名
                          ConstrainedBox(
                            constraints: styles.tileWidthConstraint,
                            child: styled.buildTextField(
                              context: context,
                              controller: TextEditingController(text: widget.identifier),
                              label: "档案名",
                              readonly: true,
                              alpha: styles.alphaSemitransparent
                            )
                          ),
                          // 用户名
                          ConstrainedBox(
                            constraints: styles.tileWidthConstraint,
                            child: styled.buildTextField(
                              context: context,
                              controller: TextEditingController(text: widget.userName),
                              label: "用户名",
                              readonly: true,
                              alpha: styles.alphaSemitransparent
                            )
                          ),
                          // 账号
                          ConstrainedBox(
                            constraints: styles.tileWidthConstraint,
                            child: styled.buildTextField(
                              context: context,
                              controller: TextEditingController(text: widget.account),
                              label: "账号",
                              readonly: true,
                              alpha: styles.alphaSemitransparent
                            ),
                          ),
                          // 移除数字
                          ConstrainedBox(
                            constraints: styles.tileWidthConstraint,
                            child: SwitchListTile(
                              value: widget.removeDigits,
                              title: const Text("移除数字"),
                              shape: styles.roundedBorder,
                              onChanged: (_) {},
                              tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(200),
                            ),
                          ),
                          // 移除字母
                          ConstrainedBox(
                            constraints: styles.tileWidthConstraint,
                            child: SwitchListTile(
                              value: widget.removeAlpha,
                              onChanged: (_){},
                              title: const Text("移除字母"),
                              shape: styles.roundedBorder,
                              tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(200),
                            ),
                          ),
                          // 移除特殊字符
                          ConstrainedBox(
                            constraints: styles.tileWidthConstraint,
                            child: SwitchListTile(
                              value: widget.removeSp,
                              onChanged: (_){},
                              title: const Text("移除特殊字符"),
                              shape: styles.roundedBorder,
                              tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(200),
                            ),
                          )
                        ]
                      ),
                      // 生成预设
                      styled.buildListTile(
                        context: context,
                        title: "生成预设",
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              utils.getPresetText(_preset),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Icon(Icons.arrow_drop_down)
                          ],
                        ),
                        alpha: styles.alphaSemitransparent,
                        onTapped: (){
                          ui.showAlertQuickWidget(
                            "选择预设",
                            RadioGroup(
                              groupValue: _preset,
                              onChanged: (value){
                                setState(() {_preset = value ?? "simple";});
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  RadioListTile(
                                    title: Text(utils.getPresetText("simple")),
                                    subtitle: Text("简易预设"),
                                    shape: styles.roundedBorder,
                                    value: "simple",
                                  ),
                                  RadioListTile(
                                    title: Text(utils.getPresetText("complex")),
                                    subtitle: Text("复杂预设，使用更复杂的生成流程"),
                                    shape: styles.roundedBorder,
                                    value: "complex"
                                  ),
                                  RadioListTile(
                                    title: Text(utils.getPresetText("bank")),
                                    subtitle: Text("生成六位的纯数字密码"),
                                    shape: styles.roundedBorder,
                                    value: "bank"
                                  ),
                                  RadioListTile(
                                    title: Text(utils.getPresetText("custom")),
                                    subtitle: Text("完全自定义整个生成流程"),
                                    shape: styles.roundedBorder,
                                    value: "custom"
                                  )
                                ],
                              )
                            ),
                            "取消",
                            context
                          );
                        },
                      ),
                      // 视情况选择是否显示配置编辑页面
                      ?_showConfigEdit(),
                      // 复制按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onCopyClicked,
                          style: styles.buttonStyle,
                          child: const Text("复制密码"),
                        ),
                      ),
                    ],
                  )
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}