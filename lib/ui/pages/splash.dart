import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/app.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final TextEditingController _pwdController = TextEditingController();
  bool isDecrypting = false;
  Widget btnChild = Text("确定");

  @override
  Widget build(BuildContext context) {
    final pwdProvider = context.watch<PwdProvider>();
    Provider.of<AppProvider>(context, listen: false).readConfig();
    
    if (isDecrypting) {
      // 正在解密
      btnChild = Row(
        spacing: styles.layoutSpacing,
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitFoldingCube(
            color: ColorScheme.of(context).primary,
            size: 15,
          ),
          Text("正在解密")
        ],
      );
    } else {
      btnChild = Text("确定");
    }
    return Scaffold(
      body: Center(
        child: Container(
          constraints: styles.tileWidthConstraint,
          padding: styles.uniInsetsSmall,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: styles.layoutSpacing,
              children: [
                Image.asset("assets/icon.png", width: 100),
                styles.spacingSizedBox,
                Text(
                  "Passtateless 已被锁定",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Column(
                  children: [
                    Text("请输入你的主密码以继续"),
                    Text("若你是第一次使用，则会自动创建主密码")
                  ],
                ),
                styles.spacingSizedBox,
                styled.buildTextField(
                  context: context,
                  passwordMode: true,
                  controller: _pwdController
                ),
                TextButton(
                  onPressed: () async {
                    // 检查是否为空
                    if (_pwdController.text.isEmpty) {
                      ui.showSnackBarQuick("不能输入空密码", context);
                      return;
                    }
                    if (!isDecrypting) {
                      // 设置解密状态
                      setState(() {
                        isDecrypting = true;
                      });
                      // 设置主密码
                      // setter会进行一次哈希处理，因此不能与controller同步
                      Provider.of<AppProvider>(context, listen: false).masterPwd = _pwdController.text;
                      // 解密档案
                      var stat = await pwdProvider.readArchive(
                        Provider.of<AppProvider>(context, listen: false).masterPwd
                      );
                      // 解密结果处理
                      if (context.mounted) {
                        setState(() {
                          isDecrypting = false;
                        });
                        if (stat != ErrorCode.success) {
                          ui.showSnackBarQuick(stat.generic, context);
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainApp()));
                        }
                      }
                    }
                  },
                  style: styles.buttonStyle,
                  child: btnChild,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}