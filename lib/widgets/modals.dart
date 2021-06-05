import 'package:flutter/material.dart';
import '../utils/settings.dart';
import '../theme.dart';
import 'rotation_loader.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ConfirmDialog extends StatefulWidget {
  // TODO: possible autoclose with success / error text.
  // TODO: prevent barrier dismissable when loading

  final String title;
  final String text;
  final String error;
  final String success;
  final String ok;
  final String cancel;
  final String close;
  final Future<bool> Function() action;

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
  }): super(key: key);

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
    style: AppFontsV2.modalTitle,
    textAlign: TextAlign.center,
  );

  Widget get _text => Text(
    widget.text ?? '',
    style: AppFontsV2.modalText,
    textAlign: TextAlign.center,
  );

  Widget get _loader => Padding(
    padding: EdgeInsets.zero,
    child:  Padding(
      padding: EdgeInsets.only(top: 20),
      child: RotationLoader(),
    ),
  );

  Widget get _error => Text(
    widget.error ?? locale(context).defaultModalError,
    style: AppFontsV2.modalText,
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
    if(result) {
      _close();
    } else {
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Widget _modalButton(String text, {
    void Function() action,
    Color color: AppColorsV2.blockBg,
    TextStyle textStyle: AppFontsV2.modalButtonPrimary,
  }) => Ink(
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
    color: AppColorsV2.purple,
  );

  Widget get _cancelButton => _modalButton(
    widget.cancel ?? locale(context).no,
    action: _loading ? null : _close,
    textStyle: AppFontsV2.modalButtonSecondary,
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
        child: _loading ? _loader : _failed ? _error : _text,
      ),
      DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColorsV2.modalBorder),
          ),
        ),
        child: Row(
          children: _failed ? [
            Expanded(child: _closeButton),
          ] : [
            Expanded(child: _cancelButton),
            SizedBox(
              width: 1,
              height: 44,
              child: ColoredBox(
                color: AppColorsV2.modalBorder,
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
        borderRadius: BorderRadius.circular(16)
      ),
      clipBehavior: Clip.hardEdge,
      backgroundColor: AppColorsV2.blockBg,
    );
  }
}


// show confirm dialog with two buttons
// for sync action.
void oldConfirmModal({
  @required BuildContext context,
  Widget title,
  Widget content,
  String confirmLabel: 'Да',
  String cancelLabel: 'Нет',
  @required void Function() action,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: title,
      content: content,
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(cancelLabel)
        ),
        TextButton(
            onPressed: () {
              action();
              Navigator.of(context).pop();
            },
            child: Text(confirmLabel)
        )
      ],
    ),
  );
}


// show dialog with info and single close button.
void infoModal({
  @required BuildContext context,
  Widget title,
  Widget content,
  String closeLabel: 'Закрыть',
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: title,
      content: content,
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(closeLabel)
        )
      ],
    ),
  );
}


// Show confirm dialog for async actions.
// action should resolve to boolean value indicating success.
// on error shows error and close button
// on success just closes.
void asyncConfirmModal({
  @required BuildContext context,
  Widget title,
  Widget content,
  Widget error,
  String confirmLabel: 'Да',
  String cancelLabel: 'Нет',
  String closeLabel: 'Закрыть',
  @required Future<bool> Function() action,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool _loading = false;
      bool _failed = false;
      return StatefulBuilder(
        builder: (BuildContext context, setState) => AlertDialog(
          title: title,
          content: _loading ? Container(
            child: Animations.modalProgressIndicator,
            alignment: Alignment.center,
            height: 40,
            margin: EdgeInsets.only(top: 20,),
          ) : (_failed ? error : content),
          actions: _failed ? [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(closeLabel),
            ),
          ] : [
            TextButton(
              onPressed: _loading ? null : () async {
                setState(() {
                  _loading = true;
                });
                if (await action()) {
                  Navigator.of(context).pop();
                } else {
                  setState(() {
                    _loading = false;
                    _failed = true;
                  });
                }
              },
              child: Text('Да'),
            ),
            TextButton(
              onPressed: _loading ? null : () {
                Navigator.of(context).pop();
              },
              child: Text('Нет'),
            ),
          ],
        ),
      );
    },
  );
}


// Dialog with a ListView in it to select from provided choices
void selectorModal<T>({
  @required BuildContext context,
  Widget title,
  List<T> choices,
  @required void Function(T) onSelect,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      title: title == null ? null : Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.gray15,)
          ),
        ),
        padding: EdgeInsets.all(16),
        child: title,
      ),
      children: choices.map<Widget>((choice) {
        final Widget option = SimpleDialogOption(
          onPressed: () {
            onSelect(choice);
            Navigator.of(context).pop();
          },
          child: Text(choice.toString()),
          padding: EdgeInsets.all(16),
        );
        if (choice == choices.last) return option;
        return DecoratedBox(
          child: option,
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: AppColors.gray15,)
            ),
          ),
        );
      }).toList(),
    ),
  );
}


// common toast with some setup available.
void toast(BuildContext context, Widget content, Color color) {
  FToast fToast = FToast();
  fToast.init(context);
  fToast.showToast(
    toastDuration: Duration(seconds: 3),
    gravity: ToastGravity.BOTTOM,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: content,
    ),
  );
}


// toast with transparent gray background and white text
void grayToast(BuildContext context, String text) {
  toast(
    context,
    Text(text, textAlign: TextAlign.center, style: AppFonts.toastText,),
    AppColors.toastBg,
  );
}


void inDevelopment(BuildContext context, {String title: 'Эта страница'}) {
  infoModal(
    context: context,
    title: Text(title),
    content: Text('Находится в разработке.'),
  );
}
