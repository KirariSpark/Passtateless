import 'package:flutter/material.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/support/share_android.dart';
import 'package:passtateless/ui/pages/support/share_windows.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/adaptive_view.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse('https://github.com/KirariSpark/Passtateless');

class SupportOptionsPage extends StatelessWidget {
  const SupportOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveView(
      leftPaneBuilder: (
        BuildContext context,
        bool isWide,
        void Function((String, String)) onItemTapped,
        bool Function((String, String)) isSelected
      ) {
        return ConstrainedBox(
          constraints: isWide ? styles.tileWidthConstraintSmall : styles.tileWidthConstraint,
          child: SingleChildScrollView(
            child: Column(
              children: [
                styled.buildListTile(
                  isFirst: true,
                  title: "GitHub 星标",
                  subtitle: "为本软件的仓库添加星标",
                  leading: Icons.star_border,
                  trailing: Icon(Icons.open_in_browser_outlined),
                  onTapped: _launchUrl,
                  context: context
                ),
                ExpansionTile(
                  leading: Icon(Icons.share),
                  title: Text("分享软件"),
                  collapsedShape: RoundedRectangleBorder(borderRadius: ui.calcRadius(isLast: true)),
                  backgroundColor: ColorScheme.of(context).surfaceContainerLow,
                  collapsedBackgroundColor: ColorScheme.of(context).surfaceContainerLow,
                  children: [
                    Material(
                      child: styled.buildListTile(
                        title: "分享 Windows 版本",
                        titleTag: "share_windows",
                        active: isSelected(("share", "windows")),
                        onTapped: () => onItemTapped(("share", "windows")),
                        context: context
                      )
                    ),
                    Material(
                      child: styled.buildListTile(
                        title: "分享 Android 版本",
                        titleTag: "share_android",
                        active: isSelected(("share", "android")),
                        onTapped: () => onItemTapped(("share", "android")),
                        context: context
                      )
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
      pageBuilder: ((String, String) tag, bool isWide) {
        switch (tag) {
          case (("share", "windows")):
            return WindowsShareGuidePage(hasPadding: !isWide, hasAppBar: !isWide);
          case (("share", "android")):
            return AndroidShareGuidePage(hasAppBar: !isWide, hasPadding: !isWide);
          default:
            return styled.buildPlaceHolder(text: "无效的Tag", context: context);
        }
      },
      padding: styles.pagePaddingAll,
      widthThreshold: styles.tileWidthConstraint.maxWidth + styles.tileWidthConstraintSmall.maxWidth +
          styles.layoutSpacing,
    );
  }
}

Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}