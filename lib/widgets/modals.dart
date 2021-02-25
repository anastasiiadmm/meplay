import 'package:flutter/material.dart';
import '../theme.dart';


// show confirm dialog with two buttons
// for sync action.
void confirmModal({
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
    builder: (BuildContext context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      title: title == null ? null : Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
            color: AppColors.gray15,
          )),
        ),
        padding: EdgeInsets.all(16),
        child: title,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 400),
        child: ListView.separated(
          shrinkWrap: choices.length < 7,
          itemBuilder: (BuildContext context, int index) => ListTile(
            title: Text(choices[index].toString()),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            onTap: () {
              onSelect(choices[index]);
              Navigator.of(context).pop();
            },
            dense: false,
          ),
          separatorBuilder: (BuildContext context, int index) => Divider(
            height: 1,
          ),
          itemCount: choices.length,
        ),
      ),
    ),
  );
}
