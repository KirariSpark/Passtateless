import 'package:flutter/material.dart';
import 'package:passtateless/modules/core/enums.dart';
import 'package:passtateless/modules/core/logger.dart';
import 'package:passtateless/modules/generator/pwd_gen_controller.dart';
import 'package:passtateless/modules/generator/values.dart';
import 'package:passtateless/modules/utils/ui.dart' as ui;
import 'package:passtateless/ui/pages/pwd/cfg_edit.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:passtateless/ui/widgets/styled.dart' as styled;
import 'package:passtateless/ui/widgets/styled_list_tile.dart';

/// “生成设置”折叠面板：预设下拉 + 自定义规则入口 + DSL 额外输入。
///
/// 仅负责渲染与交互分发，业务状态与逻辑由 [PwdGenController] 承载；
/// [onChanged] 由页面传入以触发重建（例如 `() => setState(() {})`）。
class PresetPanel extends StatefulWidget {
  final PwdGenController controller;
  final VoidCallback onChanged;

  const PresetPanel({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<PresetPanel> createState() => _PresetPanelState();
}

class _PresetPanelState extends State<PresetPanel> {
  /// 折叠面板是否展开（默认展开）
  bool _expanded = true;

  Future<void> _editCfg() async {
    appLogger.logger.i("Pushing to generator config edit page");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CfgEditPage(initialText: widget.controller.customConfig),
      ),
    );

    if (result != null && result is String) {
      widget.controller.setConfigText(result);
      widget.onChanged();
      appLogger.logger.i("Got new config with ${result.length} characters");
      if (mounted) {
        ui.showSnackBarQuick("编辑结果已保存", context);
      }
    }
  }

  /// 根据当前预设决定是否显示自定义规则入口
  Widget? _showConfigEdit() {
    if (widget.controller.preset == Presets.custom) {
      return StyledListTileSimple(
        title: "配置生成规则",
        trailing: Icon(Icons.arrow_forward),
        isLast: true,
        isFirst: true,
        onTap: _editCfg,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final children = <Widget>[
      DropdownMenu(
        label: Text("生成预设"),
        width: double.infinity,
        helperText: controller.preset.desc,
        menuStyle: MenuStyle(maximumSize: WidgetStatePropertyAll<Size>(Size(120, double.infinity)),),
        dropdownMenuEntries: [for (Presets i in Presets.values) DropdownMenuEntry(value: i, label: i.displayName)],
        onSelected: (value) {
          controller.setPreset(value ?? Presets.simple);
          widget.onChanged();
        },
        initialSelection: controller.preset,
        selectOnly: true,
      ),
    ];

    final cfgEdit = _showConfigEdit();
    if (cfgEdit != null) children.add(cfgEdit);

    if (controller.extraInputs.isNotEmpty) {
      children.add(styles.spacingSizedBox);
      for (final i in controller.extraInputs) {
        children.add(styles.spacingSizedBox);
        children.add(
          switch (i.type) {
            DslType.bool => SwitchListTile(
              title: Text(i.displayName),
              value: controller.extraSwitchValues[i.name]!,
              onChanged: (v) {
                controller.extraSwitchValues[i.name] = v;
                widget.onChanged();
              },
              shape: styles.roundedBorder,
            ),
            _ => styled.buildTextField(
              context: context,
              controller: controller.extraControllers[i.name],
              label: i.displayName,
              // int 使用数字键盘
              keyboardType: i.type == DslType.int ? TextInputType.number : null,
            ),
          },
        );
      }
    }

    if (controller.inlineInputError != null) {
      children.add(
        Text(
          controller.inlineInputError!,
          style: TextStyle(color: ColorScheme.of(context).error),
        ),
      );
    }

    final contentColor = ColorScheme.of(context).onSurface;

    // 与 StyledListTileSimple 视觉一致的卡片：surfaceContainerLow 背景 + 圆角
    return Container(
      decoration: BoxDecoration(
        borderRadius: styles.borderRadius,
        color: ColorScheme.of(context).surfaceContainerLow,
      ),
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (expanded) => _expanded = expanded,
        childrenPadding: styles.uniInsetsSmall,
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape: styles.roundedBorder,
        collapsedShape: styles.roundedBorder,
        leading: Icon(Icons.tune, color: contentColor),
        iconColor: contentColor,
        collapsedIconColor: contentColor,
        textColor: contentColor,
        collapsedTextColor: contentColor,
        title: const Text("生成设置"),
        children: children,
      ),
    );
  }
}