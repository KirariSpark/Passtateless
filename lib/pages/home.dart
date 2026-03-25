import 'package:flutter/material.dart';
import 'package:passtateless/widgets/stars.dart';
import 'package:passtateless/widgets/quick_options.dart';
import 'package:passtateless/widgets/uni_styles.dart' as styles;
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/pages/pwd_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: styles.uniInsetsSmall,
          child: Column(
            children: [
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double currentWidth = constraints.maxWidth;
                  double targetWidth = ui.calcWidthConstraint(
                    currentWidth,
                    false,
                    maxColumns: 3
                  );
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: targetWidth
                    ),
                    child: StarredPasswords()
                  );
                }
              ),
              SizedBox(height: styles.layoutSpacing),
              HomePageQuickOptions(
                onEditTapped: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PwdList()));
                },
                onBasicTapped: (){},
                onAdvancedTapped: (){}
              )
            ],
          ),
        ),
      ),
    );
  }
}
