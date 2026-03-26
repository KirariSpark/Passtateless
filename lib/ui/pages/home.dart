import 'package:flutter/material.dart';
import 'package:passtateless/ui/widgets/stars.dart';
import 'package:passtateless/ui/widgets/quick_options.dart';
import 'package:passtateless/ui/widgets/uni_styles.dart' as styles;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: styles.uniInsetsSmall,
          child: Column(
            children: [
              ConstrainedBox(
                constraints: styles.pageWidthConstraint,
                child: StarredPasswords()
              ),
              SizedBox(height: styles.layoutSpacing),
              HomePageQuickOptions(
                onEditTapped: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PwdListPage()));
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}
