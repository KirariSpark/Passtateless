import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passtateless/modules/core/enums.dart' as enums;
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/generator/parser.dart' as parser;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/cfg_edit.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:re_editor/re_editor.dart';

class PwdViewPage extends StatefulWidget {
  final String identifier;
  final String userName;
  final String account;

  const PwdViewPage({super.key, required this.identifier, required this.userName, required this.account});

  @override
  State<PwdViewPage> createState() => _PwdViewPageState();
}

class _PwdViewPageState extends State<PwdViewPage> {
  enums.Presets _preset = enums.Presets.simple;
  final CodeLineEditingController _configController = CodeLineEditingController.fromText("[{\"name\":\"toBase64\"}]");
  bool removeDigits = false;
  bool removeAlpha = false;
  bool removeSp = false;

  /// 根据当前预设决定是否显示自定义规则
  Widget? _showConfigEdit() {
    if (_preset == enums.Presets.custom) {
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
      appBar: styled.buildAppBar(
        title: "查看：${widget.identifier.isEmpty ? '未命名' : widget.identifier}",
        context: context
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
                              value: removeDigits,
                              onChanged: (value){
                                setState(() {
                                  removeDigits = !removeDigits;
                                });
                              },
                              title: const Text("移除数字"),
                              shape: styles.roundedBorder,
                              tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(styles.alphaSemitransparent),
                            ),
                          ),
                          // 移除字母
                          ConstrainedBox(
                            constraints: styles.tileWidthConstraint,
                            child: SwitchListTile(
                              value: removeAlpha,
                              onChanged: (value){
                                setState(() {
                                  removeAlpha = !removeAlpha;
                                });
                              },
                              title: const Text("移除字母"),
                              shape: styles.roundedBorder,
                              tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(styles.alphaSemitransparent),
                            ),
                          ),
                          // 移除特殊字符
                          ConstrainedBox(
                            constraints: styles.tileWidthConstraint,
                            child: SwitchListTile(
                              value: removeSp,
                              onChanged: (value){
                                setState(() {
                                  removeSp = !removeSp;
                                });
                              },
                              title: const Text("移除特殊字符"),
                              shape: styles.roundedBorder,
                              tileColor: ColorScheme.of(context).surfaceContainerLowest.withAlpha(styles.alphaSemitransparent),
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
                              _preset.displayName,
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
                                setState(() {_preset = value ?? enums.Presets.simple;});
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  RadioListTile(
                                    title: Text(enums.Presets.simple.displayName),
                                    subtitle: Text("简易预设，适用于对安全性要求不高的场景"),
                                    shape: styles.roundedBorder,
                                    value: enums.Presets.simple,
                                  ),
                                  RadioListTile(
                                    title: Text(enums.Presets.complex.displayName),
                                    subtitle: Text("使用更复杂的生成流程和 PBKDF2 算法"),
                                    shape: styles.roundedBorder,
                                    value: enums.Presets.complex
                                  ),
                                  RadioListTile(
                                    title: Text(enums.Presets.bank.displayName),
                                    subtitle: Text("生成六位的纯数字密码"),
                                    shape: styles.roundedBorder,
                                    value: enums.Presets.bank
                                  ),
                                  RadioListTile(
                                    title: Text(enums.Presets.custom.displayName),
                                    subtitle: Text("完全自定义整个生成流程"),
                                    shape: styles.roundedBorder,
                                    value: enums.Presets.custom
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
                          onPressed: () async {
                            if (<enums.Presets>[
                              enums.Presets.simple, enums.Presets.complex, enums.Presets.bank
                            ].contains(_preset)) {
                              var res = await parser.parseBuiltins(
                                _preset,
                                "${widget.identifier}: ${widget.userName} @ ${widget.account}",
                                removeAlpha: removeAlpha,
                                removeDigits: removeDigits,
                                removeSp: removeSp
                              );
                              if (res.$1 == ErrorCode.success) {
                                Clipboard.setData(ClipboardData(text: res.$2));
                                if (context.mounted) {
                                  ui.showSnackBarQuick("密码已复制", context);
                                }
                              } else {
                                if (context.mounted) {
                                  ui.showSnackBarQuick(res.$1.generic, context);
                                }
                              }
                            }
                          },
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