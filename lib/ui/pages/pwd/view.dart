import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/generator/parser.dart' as parser;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/cfg_edit.dart';
import 'package:passtateless/ui/pages/pwd/fullscreen.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:re_editor/re_editor.dart';

/// 密码记录的只读页面
///
/// 记录的 id 将被用于 Hero 动画
class PwdViewPage extends StatefulWidget {
  /// 要查看的密码记录的id
  final String id;
  /// 有AppBar时，AppBar是否要使用Hero动画
  final bool useHero;
  /// 页面是否有AppBar
  final bool hasAppBar;
  /// 页面是否有内边距
  final bool hasPadding;
  const PwdViewPage({super.key,required this.id, required this.useHero, this.hasAppBar = true, this.hasPadding = true});

  @override
  State<PwdViewPage> createState() => _PwdViewPageState();
}

class _PwdViewPageState extends State<PwdViewPage> {
  final CodeLineEditingController _configController = CodeLineEditingController.fromText("[{\"name\":\"toBase64\"}]");
  Presets _preset = Presets.simple;
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

  /// 生成密码并显示提示（返回生成的密码或错误信息）
  Future<(ErrorCode, String)> genPwd(BuildContext context, bool copy, String identifier, String userName, String account) async {
    setState(() {isGenerating = true;});
    // 生成后的处理，复制和显示snack bar
    (ErrorCode, String) postProcess((ErrorCode, String) res) {
      if (res.$1 == ErrorCode.success) {
        if (copy) {
          Clipboard.setData(ClipboardData(text: res.$2));
        }
        if (context.mounted && copy) {
          ui.showSnackBarQuick("密码已复制", context);
        }
      } else {
        if (context.mounted) {
          ui.showSnackBarQuick(res.$1.generic, context);
        }
      }
      return res;
    }
    // 实际生成
    if (<Presets>[Presets.simple, Presets.complex, Presets.bank].contains(_preset)) {
      // 使用预设
      final res = await parser.parseBuiltins(
        _preset, "$identifier: $userName @ $account",
        removeAlpha: removeAlpha, removeDigits: removeDigits, removeSp: removeSp
      );
      return postProcess(res);
    } else {
      try {
        final cfg = jsonDecode(_configController.text);
        final res = await parser.parse(
          jsonDecode(cfg), "$identifier: $userName @ $account",
          removeAlpha: removeAlpha, removeDigits: removeDigits, removeSp: removeSp
        );
        return postProcess(res);
      } catch(e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "JSON 格式错误\n${e.toString()}",
                style: TextStyle(fontFamily: "SourceCodePro"),
              ),
              showCloseIcon: true
            )
          );
        }
        return (ErrorCode.jsonFormatError, "");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pwdRecord = context.watch<PwdProvider>().getItemById(widget.id);

    return Scaffold(
      appBar: widget.hasAppBar ? styled.buildAppBar(
        title: pwdRecord["identifier"].toString().isEmpty ? '未命名' : pwdRecord["identifier"].toString(),
        titleTag: widget.useHero ? pwdRecord["id"] : null,
        context: context
      ) : null,
      body: SingleChildScrollView(
        child: Container(
          padding: widget.hasPadding ? styles.pagePaddingAll : EdgeInsets.zero,
          alignment: Alignment.center,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double maxWidth = ui.calcWidthConstraint(constraints.maxWidth, true, maxColumns: 3);
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: <Widget>[
                    styles.spacingSizedBox,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // 档案名
                        ConstrainedBox(
                          constraints: styles.tileWidthConstraint,
                          child: styled.buildTextField(
                            context: context,
                            controller: TextEditingController(text: pwdRecord["identifier"]),
                            label: "档案名",
                            readonly: true
                          )
                        ),
                        // 用户名
                        ConstrainedBox(
                          constraints: styles.tileWidthConstraint,
                          child: styled.buildTextField(
                            context: context,
                            controller: TextEditingController(text: pwdRecord["userName"]),
                            label: "用户名",
                            readonly: true
                          )
                        ),
                        // 账号
                        ConstrainedBox(
                          constraints: styles.tileWidthConstraint,
                          child: styled.buildTextField(
                            context: context,
                            controller: TextEditingController(text: pwdRecord["account"]),
                            label: "账号",
                            readonly: true
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
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            child: Column(
                              children: [
                                for (var item in Presets.values) RadioListTile(
                                  value: item,
                                  subtitle: Text(item.desc),
                                  shape: styles.roundedBorder,
                                  title: Text(item.displayName)
                                )
                              ],
                            )
                          ),
                          actionText: "取消",
                          action: (){Navigator.of(context, rootNavigator: true).pop();},
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
                                  Navigator.of(context, rootNavigator: true).pop();
                                  var temp = await genPwd(
                                    context, false, pwdRecord["identifier"],
                                    pwdRecord["userName"], pwdRecord["account"]
                                  );
                                  if (context.mounted) {
                                    if (temp.$1 == ErrorCode.success) {
                                      Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => FullscreenPwd(temp.$2))
                                      );
                                    }
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
                              await genPwd(
                                context, true, pwdRecord["identifier"],
                                pwdRecord["userName"], pwdRecord["account"]
                              );
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