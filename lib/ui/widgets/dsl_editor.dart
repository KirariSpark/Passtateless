import 'dart:math';

import 'package:flutter/material.dart';
import 'package:passtateless/modules/generator/builtins.dart';
import 'package:passtateless/ui/styles.dart' as styles;
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/a11y-dark.dart';
import 'package:re_highlight/styles/a11y-light.dart';

/// DSL 关键字（与 lexer.dart 保留字一致）
const List<String> _keywords = [
  'GroupInput',
  'Generate',
  'return',
  'raise',
  'pass',
  'AND',
  'OR',
  'str',
  'int',
  'bool',
  'true',
  'false',
];

/// 内建函数返回类型（builtins.dart 未暴露返回类型，按 docs/Grammer.md 维护；
/// 未列出的内建函数均返回 str，`if` 是解释器特设语法）
const Map<String, String> _functionReturnTypes = {
  'len': 'int',
  'if': 'any',
};

/// 由 builtins 表动态生成全部内建函数的补全项
final List<CodeFunctionPrompt> _builtinPrompts = [
  for (final fn in builtins.values)
    CodeFunctionPrompt(
      word: fn.name,
      type: _functionReturnTypes[fn.name] ?? 'str',
      parameters: {
        for (final entry in fn.params.entries)
          if (entry.value.required) entry.key: entry.value.type.label,
      },
      optionalParameters: {
        for (final entry in fn.params.entries)
          if (!entry.value.required) entry.key: entry.value.type.label,
      },
    ),
  // if 不在 builtins 中，是解释器特设的函数调用
  const CodeFunctionPrompt(
    word: 'if',
    type: 'any',
    parameters: {
      'cond': 'bool',
      'onTrue': 'any',
      'onFalse': 'any',
    },
  ),
];

/// DSL 内建函数名（built_in 高亮分组），与补全数据同源
final List<String> _builtinKeywords = [...builtins.keys, 'if'];

/// 自定义 DSL 的 re_highlight 语法规则（对应 docs/Grammer.md）
final Mode langDsl = Mode(
  name: 'DSL',
  keywords: {
    'keyword': ['GroupInput', 'Generate', 'return', 'raise', 'pass', 'AND', 'OR'],
    'type': ['str', 'int', 'bool'],
    'literal': ['true', 'false'],
    'built_in': _builtinKeywords,
  },
  contains: <Mode>[
    HASH_COMMENT_MODE, // # 行注释
    QUOTE_STRING_MODE, // "..." 字符串
    C_NUMBER_MODE, // 整数/小数
    Mode(
      // 关键字参数名（冒号前的标识符）
      className: 'attr',
      begin: r'[a-zA-Z_][a-zA-Z0-9_]*(?=\s*:)',
    ),
    Mode(
      // 运算符与括号标点
      match: r'[{}()\[\],;:!=<>+\-*/]',
      className: 'punctuation',
      relevance: 0,
    ),
  ],
);

/// 依据明暗模式取高亮主题；移除 'root' 避免其背景色覆盖编辑器底色，
/// 并补上 a11y 主题缺失的 attr / punctuation 样式
Map<String, TextStyle> _highlightTheme(Brightness brightness) {
  final base = brightness == Brightness.dark ? a11YDarkTheme : a11YLightTheme;
  return <String, TextStyle>{
    ...base,
    'attr': base['attribute']!, // 参数名：复用 attribute 配色
    'punctuation': base['comment']!, // 标点：复用 comment 配色
  }..remove('root');
}

/// 专用于当前自定义 DSL 的代码编辑器，提供关键字 / 类型 / 内建函数补全与语法高亮
class DslEditor extends StatelessWidget {
  const DslEditor({
    super.key,
    this.controller,
    this.readOnly = false,
  });

  final CodeLineEditingController? controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return CodeAutocomplete(
      viewBuilder: (context, notifier, onSelected) {
        return _DslAutocompleteView(
          notifier: notifier,
          onSelected: onSelected,
        );
      },
      promptsBuilder: DefaultCodeAutocompletePromptsBuilder(
        keywordPrompts: [
          for (final keyword in _keywords) CodeKeywordPrompt(word: keyword),
        ],
        directPrompts: _builtinPrompts,
      ),
      child: CodeEditor(
        readOnly: readOnly,
        wordWrap: false,
        controller: controller,
        style: CodeEditorStyle(
          fontFamily: 'SourceCodePro',
          fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
          backgroundColor: ColorScheme.of(context).surfaceContainerLow,
          codeTheme: CodeHighlightTheme(
            languages: {
              'dsl': CodeHighlightThemeMode(mode: langDsl),
            },
            theme: _highlightTheme(Theme.of(context).brightness),
          ),
        ),
        borderRadius: styles.borderRadius,
        indicatorBuilder: (context, editingController, chunkController, notifier) {
          return Row(
            children: [
              DefaultCodeLineNumber(
                controller: editingController,
                notifier: notifier,
              ),
              DefaultCodeChunkIndicator(
                width: 20,
                controller: chunkController,
                notifier: notifier,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 补全列表视图（参考 re_editor example 的 _DefaultCodeAutocompleteListView）
class _DslAutocompleteView extends StatefulWidget implements PreferredSizeWidget {
  static const double kItemHeight = 26;

  final ValueNotifier<CodeAutocompleteEditingValue> notifier;
  final ValueChanged<CodeAutocompleteResult> onSelected;

  const _DslAutocompleteView({
    required this.notifier,
    required this.onSelected,
  });

  @override
  Size get preferredSize => Size(
    250,
    min(kItemHeight * notifier.value.prompts.length, 150) + 2,
  );

  @override
  State<_DslAutocompleteView> createState() => _DslAutocompleteViewState();
}

class _DslAutocompleteViewState extends State<_DslAutocompleteView> {
  @override
  void initState() {
    widget.notifier.addListener(_onValueChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onValueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final prompts = widget.notifier.value.prompts;
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints.loose(widget.preferredSize),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: styles.borderRadius,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int index = 0; index < prompts.length; index++)
                _buildItem(context, index, prompts[index]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, CodePrompt prompt) {
    final scheme = ColorScheme.of(context);
    final selected = index == widget.notifier.value.index;
    return InkWell(
      onTap: () {
        widget.onSelected(
          widget.notifier.value.copyWith(index: index).autocomplete,
        );
      },
      child: Container(
        width: double.infinity,
        height: _DslAutocompleteView.kItemHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        color: selected ? scheme.secondaryContainer : null,
        child: RichText(
          text: _promptSpan(prompt, scheme),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  /// 展示补全项：关键字直接显示，字段显示 `word type`，函数显示 `word(...) type`
  TextSpan _promptSpan(CodePrompt prompt, ColorScheme scheme) {
    final wordSpan = TextSpan(
      text: prompt.word,
      style: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
    final String suffix = switch (prompt) {
      CodeKeywordPrompt() => '',
      CodeFieldPrompt(:final type) => ' $type',
      CodeFunctionPrompt(:final type) => '(...) $type',
      _ => '',
    };
    return suffix.isEmpty
        ? wordSpan
        : TextSpan(children: [
            wordSpan,
            TextSpan(
              text: suffix,
              style: TextStyle(color: scheme.primary),
            ),
          ]);
  }

  void _onValueChanged() {
    setState(() {});
  }
}
