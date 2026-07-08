import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/eval_res.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:zxcvbn/zxcvbn.dart';

/// 密码强度评估页面
class PwdEvalPage extends StatefulWidget {
  /// 有AppBar时，AppBar是否要使用Hero动画
  final bool useHero;

  /// 页面是否有AppBar
  final bool hasAppBar;

  /// 页面是否有内边距
  final bool hasPadding;

  const PwdEvalPage({super.key, required this.useHero, this.hasAppBar = true, this.hasPadding = true});

  @override
  State<PwdEvalPage> createState() => _PwdEvalPageState();
}

class _PwdEvalPageState extends State<PwdEvalPage> {
  final TextEditingController _pwdController = TextEditingController();
  Result? _evalResult;
  bool _isInputVisible = false;

  @override
  void dispose() {
    _pwdController.dispose();
    super.dispose();
  }

  void _evalPwd() {
    appLogger.logger.i("Evaluating password");
    if (_pwdController.text.isEmpty) {
      setState(() => _evalResult = null);
      appLogger.logger.e("No password provided for evaluating");
      ui.showSnackBarQuick("请输入要评估的密码", context);
      return;
    }
    setState(() => _evalResult = Zxcvbn().evaluate(_pwdController.text));
  }

  AppBar? _buildAppBar() {
    if (widget.hasAppBar) {
      return styled.buildAppBar(
        title: "密码强度", 
        context: context, 
        titleTag: widget.useHero ? HeroTags.pwdEval.tag : null
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        alignment: Alignment.topCenter,
        padding: widget.hasPadding ? styles.pagePaddingAll : null,
        child: ConstrainedBox(
          constraints: styles.pageWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              spacing: styles.layoutSpacing,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: styled.buildTextField(
                        context: context,
                        label: "密码",
                        controller: _pwdController,
                        passwordMode: !_isInputVisible
                      )
                    ),
                    styles.spacingSizedBox,
                    IconButton(
                      onPressed: _evalPwd,
                      icon: Icon(Icons.check),
                      style: styles.buttonStyle,
                    ),
                    IconButton(
                      onPressed: () => setState(() => _isInputVisible = !_isInputVisible),
                      icon: Icon(_isInputVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      style: styles.buttonStyle,
                    )
                  ],
                ),
                EvalRes(evalRes: _evalResult)
              ],
            ),
          ),
        ),
      ),
    );
  }
}