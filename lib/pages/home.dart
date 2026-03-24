import 'package:flutter/material.dart';
import 'package:passtateless/widgets/stars.dart';
import 'package:passtateless/widgets/quick_options.dart';
import 'package:passtateless/widgets/uni_styles.dart' as styles;

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
                  double targetWidth;

                  if (currentWidth < 800) {
                    targetWidth = 400;
                  } else if (currentWidth < 1200) {
                    targetWidth = 800;
                  } else {
                    targetWidth = 1200;
                  }

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: targetWidth
                    ),
                    child: StarredPasswords()
                  );
                }
              ),
              SizedBox(height: 8),
              HomePageQuickOptions(onEditTapped: (){}, onBasicTapped: (){}, onAdvancedTapped: (){})
            ],
          ),
        ),
      ),
    );
  }
}