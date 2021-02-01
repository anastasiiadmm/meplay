import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../hexagon/hexagon_widget.dart';
import '../hexagon/grid/hexagon_offset_grid.dart';
import '../models.dart';


class LoginScreen extends StatefulWidget {
  final void Function(User user) afterLogin;

  LoginScreen({Key key, @required this.afterLogin}): super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final gridSize = HexGridSize(7, 5);
  final lockTile = HexGridPoint(2, 2);
  final _phoneMask = MaskTextInputFormatter(
    mask: '+996 ### ######',
    filter: { "#": RegExp(r'[0-9]') }
  );
  KeyboardVisibilityNotification _keyboardVisibility;
  TapGestureRecognizer _userAgreementTapRecognizer;
  int _keyboardVisibilityListenerId;
  String _phone;
  String _code;

  final String _codeHint = 'Введите код подтверждения';

  @override
  void initState() {
    super.initState();
    _keyboardVisibility = KeyboardVisibilityNotification();
    _keyboardVisibilityListenerId = _keyboardVisibility.addNewListener(
      onShow: _restoreSystemOverlays
    );
    _userAgreementTapRecognizer = TapGestureRecognizer();
    _userAgreementTapRecognizer.onTap = _onUserAgreementLinkTap;
  }

  @override
  void dispose() {
    _keyboardVisibility.removeListener(_keyboardVisibilityListenerId);
    _keyboardVisibility.dispose();
    _userAgreementTapRecognizer.dispose();
    super.dispose();
  }

  void _onUserAgreementLinkTap () {
    launch('https://megacom.kg');
  }

  void _restoreSystemOverlays() {
    Timer(Duration(milliseconds: 1001), SystemChrome.restoreSystemUIOverlays);
  }

  void _phoneSubmit() {
    String phone = '';
    // do some request here
    // then
    setState(() {
      _phone = phone;
    });

  }

  HexagonWidget tileBuilder(HexGridPoint point) {
    Color color;
    Widget content;
    if (point == lockTile) {
      color = AppColors.gray5;
      content = AppIcons.lock;
    } else {
      color = AppColors.emptyTile;
    }
    return HexagonWidget.template(color: color, child: content);
  }

  Widget get _form {
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Введите номер телефона',
            style: AppFonts.screenTitle,
          ),
          Padding(
            child: TextFormField(
              inputFormatters: [_phoneMask],
              keyboardType: TextInputType.phone,
              style: AppFonts.inputText,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(13),
                hintText: '+996 --- ------',
                hintStyle: AppFonts.inputHint,
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(6)
                ),
                errorMaxLines: 1
              ),
              validator: (value) {print(value); return value;},
            ),
            padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
          ),
          SizedBox(
            width: double.infinity,
            child: FlatButton(
              onPressed: _phoneSubmit,
              color: AppColors.megaPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
              padding: EdgeInsets.fromLTRB(0, 14, 0, 14),
              child: Text('Продолжить', style: AppFonts.formBtn,),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _appBar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 100,
      leading: FlatButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(child: AppIcons.back, padding: EdgeInsets.fromLTRB(0, 0, 5, 0),),
            Text('Назад', style: AppFonts.backBtn,),
          ],
        ),
      ),
    );
  }

  Widget get _hexBackground {
    return ClipRect(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Container(
          margin: EdgeInsets.only(bottom: 60),
          child: Center(
            child: HexagonOffsetGrid.oddPointy(
              columns: gridSize.cols,
              rows: gridSize.rows,
              symmetrical: true,
              color: Colors.transparent,
              hexagonPadding: 8,
              hexagonBorderRadius: 15,
              hexagonWidth: 174,
              buildHexagon: tileBuilder,
            ),
          ),
        ),
      ),
    );
  }

  Widget get _userAgreement {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: "Нажимая на кнопку, Вы принимаете условия ",
              style: AppFonts.loginAgreement,
            ),
            TextSpan(
              text: "Пользовательского соглашения",
              style: AppFonts.loginAgreementLink,
              recognizer: _userAgreementTapRecognizer,
            ),
            TextSpan(
              text: ".",
              style: AppFonts.loginAgreement,
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.megaPurple,
      resizeToAvoidBottomInset: false,
      appBar: _appBar,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _hexBackground,
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 375),
                child: _form,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 375),
                child: _userAgreement,
              ),
            ),
          )
        ],
      ),
    );
  }
}
