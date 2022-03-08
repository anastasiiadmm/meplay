import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/orientation_helper.dart';
import '../utils/settings.dart';
import 'app_icon_button.dart';
import 'circle.dart';
import 'rotation_loader.dart';

class ConfirmDialog extends StatefulWidget {
  final String title;
  final String text;
  final String error;

  // TODO: possible display of success text instead of autopop after success.
  final String success;

  final String ok;
  final String cancel;
  final String close;
  final Future<bool> Function() action;
  final bool autoPop;

  ConfirmDialog({
    Key key,
    this.title,
    this.text,
    this.error,
    this.success,
    this.ok,
    this.cancel,
    this.close,
    @required this.action,
    this.autoPop: true,
  }) : super(key: key);

  @override
  _ConfirmDialogState createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool _loading;
  bool _failed;

  @override
  void initState() {
    _loading = false;
    _failed = false;
    super.initState();
  }

  Widget get _title => Text(
        widget.title ?? locale(context).defaultModalTitle,
        style: AppFonts.modalTitle,
        textAlign: TextAlign.center,
      );

  Widget get _text => Text(
        widget.text ?? '',
        style: AppFonts.modalText,
        textAlign: TextAlign.center,
      );

  Widget get _loader => Padding(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: RotationLoader(),
        ),
      );

  Widget get _error => Text(
        widget.error ?? locale(context).defaultModalError,
        style: AppFonts.modalText,
        textAlign: TextAlign.center,
      );

  Future<void> _action() async {
    setState(() {
      _loading = true;
    });
    bool result;
    try {
      result = await widget.action();
    } catch (e) {
      print(e);
      result = false;
    }
    if (mounted) {
      if (result) {
        if (widget.autoPop) _close();
      } else {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Widget _modalButton(
    String text, {
    void Function() action,
    Color color: AppColors.blockBg,
    TextStyle textStyle: AppFonts.modalButtonPrimary,
  }) =>
      Ink(
        color: color,
        height: 44,
        child: InkWell(
          onTap: _loading ? null : action,
          child: Padding(
            padding: EdgeInsets.only(top: 9),
            child: Text(
              text,
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

  Widget get _closeButton => _modalButton(
        widget.close ?? locale(context).close,
        action: _close,
      );

  Widget get _okButton => _modalButton(
        widget.ok ?? locale(context).yes,
        action: _loading ? null : _action,
        color: AppColors.purple,
      );

  Widget get _cancelButton => _modalButton(
        widget.cancel ?? locale(context).no,
        action: _loading ? null : _close,
        textStyle: AppFonts.modalButtonSecondary,
      );

  Widget get _content => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _title,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: _loading
                ? _loader
                : _failed
                    ? _error
                    : _text,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.modalBorder),
              ),
            ),
            child: Row(
              children: _failed
                  ? [
                      Expanded(child: _closeButton),
                    ]
                  : [
                      Expanded(child: _cancelButton),
                      SizedBox(
                        width: 1,
                        height: 44,
                        child: ColoredBox(
                          color: AppColors.modalBorder,
                        ),
                      ),
                      Expanded(child: _okButton),
                    ],
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: _content,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      backgroundColor: AppColors.blockBg,
    );
  }
}

class SelectorModal<T> extends StatelessWidget {
  final String title;
  final List<T> choices;
  final String Function(T item) itemTitle;
  final T selected;
  final void Function(T item) onSelect;

  SelectorModal({
    Key key,
    @required this.title,
    @required this.choices,
    @required this.itemTitle,
    this.selected,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool fullscreen = OrientationHelper.isFullscreen(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      backgroundColor: AppColors.blockBg,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: fullscreen ? 75 : 49,
                    ),
                    child: Text(
                      title,
                      style: AppFonts.screenTitle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: choices
                            .map<Widget>((item) => InkWell(
                                  onTap: () {
                                    onSelect(item);
                                    Navigator.of(context).pop();
                                  },
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppColors.decorativeGray,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 7,
                                          horizontal: 20,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                itemTitle(item),
                                                style: AppFonts.textSecondary,
                                              ),
                                            ),
                                            if (item == selected)
                                              AppIcons.check_null,
                                          ],
                                        )),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: fullscreen ? 42 : 16,
                child: Circle(
                  color: AppColors.white,
                  radius: 14,
                  child: AppIconButton(
                    icon: AppIcons.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
