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
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ui.calcWidthConstraint(constraints.maxWidth, true, maxColumns: 3, usePadding: true)
                    ),
                    child: StarredPasswords()
                  ),
                  SizedBox(height: styles.layoutSpacing),
                  HomePageQuickOptions(
                    maxWidth: ui.calcWidthConstraint(constraints.maxWidth, true, maxColumns: 3, usePadding: true),
                    onEditTapped: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PwdListPage()));
                    }
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
