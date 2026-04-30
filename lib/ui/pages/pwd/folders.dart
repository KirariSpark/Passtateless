import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/error_codes.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/providers/app_provider.dart';
import 'package:passtateless/modules/providers/pwd_provider.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/list.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/expandable_fab.dart';
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:provider/provider.dart';

/// 密码文件夹列表界面
class PwdFolderPage extends StatefulWidget {
  /// 有AppBar时，AppBar是否要使用Hero动画
  final bool useHero;
  /// 页面是否有AppBar
  final bool hasAppBar;
  /// 页面是否有内边距
  final bool hasPadding;
  const PwdFolderPage({super.key, required this.useHero, this.hasAppBar = true, this.hasPadding = true});

  @override
  State<PwdFolderPage> createState() => _PwdFolderPageState();
}

class _PwdFolderPageState extends State<PwdFolderPage> {
  final TextEditingController folderName = TextEditingController();

  Widget _buildMainBody(List<String> folders) {
    return Container(
      alignment: Alignment.topCenter,
      padding: widget.hasPadding ? styles.pagePadding : EdgeInsets.all(0),
      child: Container(
        constraints: styles.tileWidthConstraint,
        decoration: BoxDecoration(
          borderRadius: styles.borderRadius,
          color: ColorScheme.of(context).surfaceContainerLow
        ),
        clipBehavior: Clip.antiAlias,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: folders.length,
          itemBuilder: (BuildContext context, int index) {
            final String displayTitle = folders[index].isEmpty ? "未分类" : folders[index];
            final bool isFirst = index == 0;
            final bool isLast = index == folders.length - 1;
            return Material(
              child: styled.buildListTileAdvanced(
                onRightClick: () {
                  ui.showBottomSheetQuick(
                    context: context,
                    title: displayTitle,
                    children: [
                      styled.buildListTile(
                        title: "重命名",
                        leading: Icons.edit_outlined,
                        isFirst: true,
                        onTapped: () {
                          appLogger.logger.i("Trying to rename folder ${folders[index]}");
                          Navigator.pop(context);
                          // 内置文件夹 未分类 不能重命名
                          if (folders[index] == "") {
                            appLogger.logger.e("Folder (empty string) is builtin and can not be renamed");
                            ui.showSnackBarQuick("你不能重命名此文件夹", context);
                            return;
                          }
                          ui.showAlertDialogQuick(
                            title: "重命名：$displayTitle",
                            content: styled.buildTextField(context: context, controller: folderName, label: "新名称"),
                            action: () => Navigator.of(context).pop(),
                            actionText: "取消",
                            action2: () {
                              appLogger.logger.i("Renaming folder to ${folderName.text}");
                              var res = Provider.of<PwdProvider>(context, listen: false).renameFolder(
                                folders[index], folderName.text
                              );
                              if (res == ErrorCode.success) {
                                appLogger.logger.i("Renamed successfully");
                                Navigator.of(context).pop();
                              } else {
                                appLogger.logger.e("Can not rename folder: ${res.code}");
                                ui.showSnackBarQuick(res.generic, context);
                              }
                            },
                            action2Text: "确定",
                            context: context
                          );
                        },
                        context: context
                      ),
                      styled.buildListTile(
                        title: "删除",
                        leading: Icons.delete_outline,
                        isLast: true,
                        onTapped: () {
                          Navigator.pop(context);
                          // 未分类 文件夹是内置文件夹，不能删除
                          if (folders[index].isEmpty) {
                            appLogger.logger.i("folder (empty string) is builtin and can not be deleted");
                            ui.showSnackBarQuick("你不能删除此文件夹", context);
                          } else {
                            ui.showConfirmDialogQuick(
                              context: context,
                              info: "确定要删除文件夹 ${folders[index]} 吗？\n你会永远失去它（真的很久）",
                              function: () {
                                appLogger.logger.i("Trying to delete folder ${folders[index]}");
                                Provider.of<PwdProvider>(context, listen: false).removeFolder(folders[index]);
                                appLogger.logger.i("Folder deleted");
                                Navigator.of(context).pop();
                              },
                              title: '确认删除'
                            );
                          }
                        },
                        context: context
                      )
                    ]
                  );
                },
                title: displayTitle,
                titleTag: folders[index],
                onTapped: (){
                  appLogger.logger.i("Pushing to page listing items in folder ${folders[index]}");
                  Navigator.push(
                    context,
                    ui.switchRoute(
                      Provider.of<AppProvider>(context, listen: false).currentNavMode,
                      builder: (context) => PwdListPage(folder: folders[index], useHero: true)
                    )
                  );
                },
                isFirst: isFirst,
                isLast: isLast,
                context: context
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildLeftPage({
    required List<String> folders,
    required BuildContext context
  }) {
    return Scaffold(
      appBar: widget.hasAppBar
        ? styled.buildAppBar(title: "资料夹", context: context, titleTag: widget.useHero ? "folders" : null) : null,
      body: _buildMainBody(folders),
      floatingActionButton: ExpandableFab(
        distance: 64,
        children: [
          // 保存更改
          styled.buildElevatedButton(
            child: Row(
              spacing: styles.layoutSpacing,
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.save_outlined), Text("保存更改")],
            ),
            context: context,
            onPressed: () async {
              appLogger.logger.i("Saving changes in password archive");
              ui.showSnackBarQuick("正在保存", context);
              var stat = await Provider.of<PwdProvider>(context, listen: false).saveArchive(
                  Provider.of<AppProvider>(context, listen: false).masterPwd
              );
              if (context.mounted) {
                if (stat == ErrorCode.success) {
                  appLogger.logger.i("Saved successfully");
                  ui.showSnackBarQuick("你的档案已保存", context);
                } else {
                  appLogger.logger.i("Can not save archive: ${stat.code}");
                  ui.showSnackBarQuick(stat.generic, context);
                }
              }
            }
          ),
          // 新建文件夹
          styled.buildElevatedButton(
            child: Row(
              spacing: styles.layoutSpacing,
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.create_new_folder_outlined), Text("新资料夹")],
            ),
            context: context,
            onPressed: (){
              ui.showAlertDialogQuick(
                title: "新建文件夹",
                content: styled.buildTextField(label: "文件夹名", controller: folderName, context: context),
                action: () => Navigator.of(context).pop(),
                actionText: "取消",
                action2: () {
                  appLogger.logger.i("Add folder ${folderName.text}");
                  var stat = Provider.of<PwdProvider>(context, listen: false).addFolder(folderName.text);
                  if (stat == ErrorCode.success) {
                    appLogger.logger.i("Added successfully");
                    Navigator.of(context).pop();
                  } else {
                    appLogger.logger.e("Can not add folder: ${stat.code}");
                    ui.showSnackBarQuick(stat.generic, context);
                  }
                },
                action2Text: "确定",
                context: context
              );
            }
          ),
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> folders = context.watch<PwdProvider>().pwdFolders;
    return _buildLeftPage(folders: folders, context: context);
  }
}