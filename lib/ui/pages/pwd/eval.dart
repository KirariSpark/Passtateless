import 'package:flutter/material.dart';
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
  Result? _res;
  bool _visible = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:widget.hasAppBar
        ? styled.buildAppBar(title: "密码强度", context: context, titleTag: widget.useHero ? "pwdEval" : null)
        : null,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          padding: widget.hasPadding ? styles.pagePadding : null,
          constraints: styles.pageWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              spacing: styles.layoutSpacing,
              children: <Widget>[
                SizedBox(), // 这个空盒子用来防止看不到下面的label
                Row(
                  spacing: styles.layoutSpacing,
                  children: [
                    Expanded(
                      child: styled.buildTextField(
                        context: context,
                        label: "评估对象",
                        controller: _pwdController,
                        passwordMode: !_visible
                      )
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: (){
                            appLogger.logger.i("Evaluating password");
                            if (_pwdController.text.isEmpty) {
                              setState(() {
                                _res = null;
                              });
                              appLogger.logger.e("No password provided");
                              ui.showSnackBarQuick("请输入要评估的密码", context);
                              return;
                            } else {
                              setState(() {
                                _res = Zxcvbn().evaluate(_pwdController.text);
                              });
                            }
                          },
                          icon: Icon(Icons.check),
                          style: styles.buttonStyle,
                        ),
                        IconButton(
                          onPressed: (){
                            setState(() {
                              _visible = !_visible;
                            });
                          },
                          icon: Icon(_visible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          style: styles.buttonStyle,
                        )
                      ],
                    )
                  ],
                ),
                EvalRes(evalRes: _res,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}