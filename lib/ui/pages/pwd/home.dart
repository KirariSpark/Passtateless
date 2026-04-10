import 'package:flutter/material.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/eval.dart';
import 'package:passtateless/ui/pages/pwd/folders.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/quick_options.dart';
import 'package:passtateless/ui/widgets/stars.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        padding: styles.uniInsetsSmall,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              spacing: styles.layoutSpacing,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ui.calcWidthConstraint(constraints.maxWidth, true, maxColumns: 2, usePadding: true)
                  ),
                  child: StarredPasswords()
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ui.calcWidthConstraint(constraints.maxWidth, true, maxColumns: 2, usePadding: true)
                  ),
                  child: HomePageQuickOptions(
                    onEditTapped: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PwdFolderPage()));
                    },
                    onEvalTapped: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PwdEvalPage()));
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
