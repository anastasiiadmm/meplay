import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:url_launcher/url_launcher.dart';
import '../hexagon/hexagon_widget.dart';
import '../hexagon/grid/hexagon_offset_grid.dart';
import '../theme.dart';
import '../models.dart';
import '../api_client.dart';


class LoginHexBackground extends StatelessWidget {
  final gridSize = HexGridSize(7, 5);
  final lockTile = HexGridPoint(2, 2);

  HexagonWidget _tileBuilder(HexGridPoint point) {
    Color color;
    Widget content;
    if (point == lockTile) {
      color = AppColors.gray5;
      content = AppIcons.lockBig;
    } else {
      color = AppColors.emptyTile;
    }
    return HexagonWidget.template(color: color, child: content);
  }

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.transparent,
              hexagonPadding: 8,
              hexagonBorderRadius: 15,
              hexagonWidth: 174,
              buildHexagon: _tileBuilder,
            ),
          ),
        ),
      ),
    );
  }
}


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final _phoneMask = MaskTextInputFormatter(
    mask: '+996 ### ######',
    filter: { "#": RegExp(r'[0-9]') },
  );
  final _codeMask = MaskTextInputFormatter(
    mask: '# # # # # #',
    filter: { '#': RegExp(r'[0-9]') },
  );
  final _keyboardVisibility = KeyboardVisibilityNotification();
  final _userAgreementTapDetector = TapGestureRecognizer();
  final _sendSmsTapDetector = TapGestureRecognizer();
  final _inputController = TextEditingController();
  final _hexBackground = LoginHexBackground();
  int _keyboardVisibilityListenerId;
  bool _waitingForSms = false;
  String _phone;
  TextEditingValue _phoneValue;
  String _code;
  Timer _smsTimer;
  int _time = -1;
  bool _allowContinue = false;
  bool _loading = false;
  String _error;

  @override
  void initState() {
    super.initState();
    _keyboardVisibilityListenerId = _keyboardVisibility.addNewListener(
      onShow: _restoreSystemOverlays,
    );
    _userAgreementTapDetector.onTap = _viewUserAgreement;
    _sendSmsTapDetector.onTap = _sendSms;
  }

  @override
  void dispose() {
    _keyboardVisibility.removeListener(_keyboardVisibilityListenerId);
    _keyboardVisibility.dispose();
    _userAgreementTapDetector.dispose();
    _sendSmsTapDetector.dispose();
    _inputController.dispose();
    _stopCodeTimer();
    super.dispose();
  }

  void _viewUserAgreement() {
    launch('https://megacom.kg');
  }

  void _restoreSystemOverlays() {
    Timer(Duration(milliseconds: 1001), SystemChrome.restoreSystemUIOverlays);
  }

  void _continue() {
    if (_waitingForSms) {
      _code = _inputController.text.replaceAll(' ', '');
      _authenticate();
    } else {
      if (_time < 0) {
        _phoneValue = _inputController.value;
        _phone = _inputController.text.replaceAll(' ', '').replaceAll('+', '');
        _sendSms();
      } else {
        _enterCode();
      }
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
    });
    try {
      User user = await ApiClient.auth(_phone, _code);
      await _saveUser(user);
      Navigator.of(context).pop<User>(user);
    } on ApiException catch(e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', user.toJson());
  }

  Future<void> _sendSms() async {
    setState(() {
      _loading = true;
    });
    try {
      await ApiClient.requestPassword(_phone);
      setState(() {
        _time = 180;
        _error = null;
        _loading = false;
        _waitingForSms = true;
        _allowContinue = false;
      });
      _startCodeTimer();
      _inputController.clear();
    } on ApiException catch(e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  void _enterCode() {
    setState(() {
      _error = null;
      _loading = false;
      _waitingForSms = true;
      _allowContinue = false;
    });
    _inputController.clear();
  }

  String get _timeDisplay {
    int minutes = _time ~/ 60;
    int seconds = _time % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _startCodeTimer() {
    _smsTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_time < 1) {
        timer.cancel();
      }
      setState(() {
        _time -= 1;
      });
    });
  }

  void _stopCodeTimer() {
    _smsTimer?.cancel();
  }

  void _changePhone() {
    _inputController.value = _phoneValue;
    setState(() {
      _waitingForSms = false;
    });
    _inputChanged(_inputController.text);
  }

  void _back() {
    if (_waitingForSms) {
      _changePhone();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _fieldSubmit(String value) {
    if (_allowContinue) {
      _continue();
    }
  }

  bool _inputIsCorrect(String value) {
    value = value.replaceAll(' ', '');
    if(_waitingForSms) {
      return value.length >= 4;
    } else {
      return value.length == 13;
    }
  }

  void _inputChanged(String value) {
    setState(() {
      _allowContinue = _inputIsCorrect(value);
    });
  }

  Widget get _form {
    List<Widget> formElements = [
      Text(
        _waitingForSms
          ? 'Вам было отправлено смс сообщение с персональным кодом.'
          : 'Введите номер телефона',
        style: AppFonts.screenTitle,
        textAlign: TextAlign.center,
      ),
      Padding(
        child: TextFormField(
          inputFormatters: [_waitingForSms ? _codeMask : _phoneMask],
          keyboardType: TextInputType.phone,
          style: AppFonts.loginInputText,
          textAlign: TextAlign.center,
          controller: _inputController,
          onFieldSubmitted: _fieldSubmit,
          onChanged: _inputChanged,
          autocorrect: false,
          textInputAction: TextInputAction.send,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(13),
            hintText: _waitingForSms ? 'Введите код подтверждения' : '+996 --- ------',
            hintStyle: AppFonts.loginInputHint,
            fillColor: AppColors.white,
            filled: true,
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(6),
            ),
            errorMaxLines: 1
          ),
        ),
        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
      ),
    ];
    if (_error != null) {
      formElements.add(
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: AppColors.transparentDark,
          ),
          child: Text(
            _error,
            style: AppFonts.loginError,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          )
        ),
      );
    }
    formElements.add(
      SizedBox(
        width: double.infinity,
        child: FlatButton(
          onPressed: _allowContinue ? _continue : null,
          color: AppColors.megaPurple,
          disabledColor: AppColors.disabledPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide.none,
          ),
          padding: EdgeInsets.fromLTRB(0, 14, 0, 14),
          child: Text(
            'Продолжить',
            style: _allowContinue ? AppFonts.formBtn : AppFonts.formBtnDisabled,
          ),
        ),
      ),
    );
    if (_waitingForSms) {
      formElements.add(_timerString);
    }
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: formElements,
      ),
    );
  }

  Widget get _timerString {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: (_time < 0) ? RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'Повторно отправить сообщение',
          recognizer: _sendSmsTapDetector,
          style: AppFonts.smsTimerLink,
        )
      ) : Text (
        'Повторная отправка сообщения через $_timeDisplay',
        style: AppFonts.smsTimer,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget get _appBar {
    return AppBar(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: double.infinity,
      leading: FlatButton(
        onPressed: _back,
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

  Widget get _userAgreement {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: "Нажимая на кнопку, Вы принимаете условия ",
              style: AppFonts.userAgreement,
            ),
            TextSpan(
              text: "Пользовательского соглашения",
              style: AppFonts.userAgreementLink,
              recognizer: _userAgreementTapDetector,
            ),
            TextSpan(
              text: ".",
              style: AppFonts.userAgreement,
            ),
          ],
        )
    );
  }

  Future<bool> _willPop() async {
    if(_waitingForSms) {
      _changePhone();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackItems = [
      _hexBackground,
      Align(
        alignment: Alignment.center,
        child: Padding(
          // 46 is a magic
          padding: EdgeInsets.fromLTRB(15, _waitingForSms ? 46 : 30, 15, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 375),
            child: _form,
          ),
        ),
      ),
    ];
    if (!_waitingForSms) {
      stackItems.add(Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 375),
            child: _userAgreement,
          ),
        ),
      ));
    }
    return WillPopScope(
      child: Scaffold(
        backgroundColor: AppColors.megaPurple,
        resizeToAvoidBottomInset: false,
        appBar: _appBar,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: stackItems,
        ),
      ),
      onWillPop: _willPop
    );
  }
}


// TODO: on tap outside hide kb
// semi-transparent bg behind form
// auto detect sms
// display loading circle,
// persist user in base.
