import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/generator/parser.dart' as parser;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/cfg_edit.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/pages/pwd/fullscreen.dart';
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
  Presets _preset = Presets.simple;
  final CodeLineEditingController _configController = CodeLineEditingController.fromText("[{\"name\":\"toBase64\"}]");
  bool isGenerating = false;
  bool removeDigits = false;
  bool removeAlpha = false;
  bool removeSp = false;

  /// 根据当前预设决定是否显示自定义规则
  Widget? _showConfigEdit() {
    if (_preset == Presets.custom) {
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
        alpha: styles.alphaAlmostTransparent,
        isLast: true,
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

  /// 生成密码并显示提示
  Future<String> genPwd(BuildContext context, bool copy) async {
    setState(() {isGenerating = true;});
    if (<Presets>[
      Presets.simple, Presets.complex, Presets.bank
    ].contains(_preset)) {
      var res = await parser.parseBuiltins(
          _preset, "${widget.identifier}: ${widget.userName} @ ${widget.account}",
          removeAlpha: removeAlpha, removeDigits: removeDigits, removeSp: removeSp
      );
      if (res.$1 == ErrorCode.success) {
        if (copy) {
          Clipboard.setData(ClipboardData(text: res.$2));
        }
        if (context.mounted && copy) {
          ui.showSnackBarQuick("密码已复制", context);
        }
        return res.$2;
      } else {
        if (context.mounted) {
          ui.showSnackBarQuick(res.$1.generic, context);
        }
        return res.$1.generic;
      }
    } else {
      return "Coming S∞n";
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
        child: Container(
          padding: styles.pagePaddingAll,
          alignment: Alignment.center,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double maxWidth = ui.calcWidthConstraint(constraints.maxWidth, true, maxColumns: 3);
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
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
                            tileColor: ColorScheme.of(context).primaryContainer.withAlpha(styles.alphaAlmostTransparent),
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
                            tileColor: ColorScheme.of(context).primaryContainer.withAlpha(styles.alphaAlmostTransparent),
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
                            tileColor: ColorScheme.of(context).primaryContainer.withAlpha(styles.alphaAlmostTransparent),
                          ),
                        )
                      ]
                    ),
                    styles.spacingSizedBox,
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
                      alpha: styles.alphaAlmostTransparent,
                      isFirst: true,
                      isLast: _preset == Presets.custom ? false : true,
                      onTapped: (){
                        ui.showAlertDialogQuick(
                          title: "选择预设",
                          content: RadioGroup(
                            groupValue: _preset,
                            onChanged: (value){
                              setState(() {_preset = value ?? Presets.simple;});
                              Navigator.pop(context);
                            },
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text(Presets.simple.displayName),
                                  subtitle: Text("简易预设，适用于对安全性要求不高的场景"),
                                  shape: styles.roundedBorder,
                                  value: Presets.simple,
                                ),
                                RadioListTile(
                                  title: Text(Presets.complex.displayName),
                                  subtitle: Text("使用更复杂的生成流程和 PBKDF2 算法，可能较慢"),
                                  shape: styles.roundedBorder,
                                  value: Presets.complex
                                ),
                                RadioListTile(
                                  title: Text(Presets.bank.displayName),
                                  subtitle: Text("基于 PBKDF2 算法生成六位的纯数字密码，可能较慢"),
                                  shape: styles.roundedBorder,
                                  value: Presets.bank
                                ),
                                RadioListTile(
                                  title: Text(Presets.custom.displayName),
                                  subtitle: Text("使用 JSON 完全自定义整个生成流程"),
                                  shape: styles.roundedBorder,
                                  value: Presets.custom
                                )
                              ],
                            )
                          ),
                          actionText: "取消",
                          action: (){Navigator.pop(context);},
                          context: context
                        );
                      },
                    ),
                    // 视情况选择是否显示配置编辑页面
                    ?_showConfigEdit(),
                    styles.spacingSizedBox,
                    // 按钮
                    Row(
                      spacing: styles.layoutSpacing,
                      children: [
                        // 查看密码
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isGenerating ? null : () async {
                              ui.showConfirmDialogQuick(
                                context: context,
                                function: () async {
                                  Navigator.pop(context);
                                  var temp = await genPwd(context, false);
                                  if (context.mounted) {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => FullscreenPwd(temp)));
                                  }
                                  // 启用按钮
                                  setState(() {isGenerating = false;});
                                },
                                title: "危险操作",
                                info: "此操作将会显示你的密码，以便于你的记忆。\n请确保周围没有人能够窥视到你的屏幕。"
                              );
                            },
                            style: styles.buttonStyle,
                            child: Text("查看密码"),
                          ),
                        ),
                        // 复制密码
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isGenerating ? null : () async {
                              // 开始生成
                              await genPwd(context, true);
                              // 启用按钮
                              setState(() {isGenerating = false;});
                            },
                            style: styles.buttonStyle,
                            child: const Text("复制密码"),
                          ),
                        )
                      ],
                    ),
                  ],
                )
              );
            },
          ),
        ),
      ),
    );
  }
}