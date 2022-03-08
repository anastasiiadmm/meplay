import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api_client.dart';
import '../channel.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/fcm_helper.dart';
import '../utils/settings.dart';

const String appHash = 'rgYa0J5D1z4';

class LoginScreen extends StatefulWidget {
  static const loginHint = '+996 --- ------';
  static const smsHint = '******';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with CodeAutoFill {
  final MaskTextInputFormatter _phoneMask = MaskTextInputFormatter(
    mask: LoginScreen.loginHint,
    filter: {"-": RegExp(r'[0-9]')},
  );
  final MaskTextInputFormatter _codeMask = MaskTextInputFormatter(
    mask: LoginScreen.smsHint,
    filter: {'*': RegExp(r'[0-9]')},
  );
  final TapGestureRecognizer _userAgreementTapDetector = TapGestureRecognizer();
  final TapGestureRecognizer _sendSmsTapDetector = TapGestureRecognizer();
  final TextEditingController _inputController = TextEditingController();
  bool _waitingForSms = false;
  String _phone;
  String _phoneText;
  String _code;
  Timer _smsTimer;
  int _time = -1;
  bool _allowContinue = false;
  String _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _userAgreementTapDetector.onTap = _viewUserAgreement;
    _sendSmsTapDetector.onTap = _sendSms;
  }

  @override
  void dispose() {
    cancel(); // CodeAutoFill methods
    unregisterListener(); // CodeAutoFill methods
    _userAgreementTapDetector.dispose();
    _sendSmsTapDetector.dispose();
    _inputController.dispose();
    _stopCodeTimer();
    super.dispose();
  }

  void _viewUserAgreement() {
    launch('https://megacom.kg');
  }

  Future<void> _restoreSystemOverlays() async {
    if (!await isTv()) {
      Timer(Duration(milliseconds: 1001), SystemChrome.restoreSystemUIOverlays);
    }
  }

  void _continue() {
    if (_waitingForSms) {
      _code = _inputController.text.replaceAll(' ', '');
      _authenticate();
    } else {
      if (_inputController.text == _phoneText) {
        if (_time < 0)
          _sendSms();
        else
          _enterCode();
      } else {
        _phoneText = _inputController.text;
        _phone = _inputController.text.replaceAll(' ', '').replaceAll('+', '');
        _sendSms();
      }
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
    });
    try {
      User user = await ApiClient.auth(_phone, _code);
      await User.setUser(user);
      await Channel.fullReload();
      FCMHelper.instance?.sendToken();
      Navigator.of(context).pop<User>(user);
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _sendSms() async {
    setState(() {
      _loading = true;
    });
    try {
      if (!await isTv()) {
        listenForCode();
      }
    } on PlatformException catch (e) {
      print(e);
    }
    try {
      await ApiClient.requestPassword(_phone);
      setState(() {
        _time = 180;
        _error = null;
        _loading = false;
        _waitingForSms = true;
        _allowContinue = false;
      });
      _stopCodeTimer();
      _startCodeTimer();
      _inputController.clear();
    } on ApiException catch (e) {
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
    _inputController.text = _phoneText;
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
    if (_waitingForSms) {
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

  @override
  void codeUpdated() {
    _inputController.text = code.split('').join(" ");
    setState(() {
      _allowContinue = true;
    });
    _continue();
  }

  Widget get _appBar {
    return AppBar(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _back,
        icon: AppIcons.chevron_left_null,
      ),
    );
  }

  Future<bool> _willPop() async {
    if (_waitingForSms) {
      _changePhone();
      return false;
    }
    return true;
  }

  Widget get _lock {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 54),
      child: AppImages.lock_null,
    );
  }

  Widget get _label {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Text(
        _waitingForSms ? locale(context).loginSms : locale(context).loginLogin,
        style: AppFonts.textPrimary,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget get _input {
    return Form(
      child: Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus) _restoreSystemOverlays();
        },
        child: TextFormField(
          inputFormatters: [_waitingForSms ? _codeMask : _phoneMask],
          keyboardType: TextInputType.phone,
          style: AppFonts.input,
          textAlign: TextAlign.center,
          controller: _inputController,
          onFieldSubmitted: _fieldSubmit,
          onChanged: _inputChanged,
          autocorrect: false,
          autofocus: true,
          textInputAction: TextInputAction.send,
          autofillHints: [
            _waitingForSms
                ? AutofillHints.oneTimeCode
                : AutofillHints.telephoneNumber,
          ],
          cursorColor: AppColors.itemFocus,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.phone, color: AppColors.white,),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            hintText:
                _waitingForSms ? LoginScreen.smsHint : LoginScreen.loginHint,
            hintStyle: AppFonts.inputPlaceholder,
            fillColor: AppColors.blockBg,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _error == null ? AppColors.item : AppColors.red,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _error == null ? AppColors.itemFocus : AppColors.red,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget get _errorString {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 3.2, 0, 3.2),
      child: Text(
        _error,
        style: AppFonts.inputError,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget get _button {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        child: FlatButton(
          onPressed: _allowContinue ? _continue : null,
          color: AppColors.item,
          disabledColor: AppColors.grayDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide.none,
          ),
          padding: EdgeInsets.fromLTRB(10, 14, 10, 18),
          child: Text(
            locale(context).loginContinue,
            style: _allowContinue
                ? AppFonts.largeButton
                : AppFonts.largeButtonDisabled,
          ),
        ),
      ),
    );
  }

  Widget get _timerString {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: (_time < 0)
          ? RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: locale(context).loginSmsResend,
                recognizer: _sendSmsTapDetector,
                style: AppFonts.smallText,
              ),
            )
          : Text(
              locale(context).loginSmsWait + ' ' + _timeDisplay,
              style: AppFonts.smallTextMute,
              textAlign: TextAlign.center,
            ),
    );
  }

  Widget get _space {
    return Expanded(child: Container());
  }

  Widget get _userAgreement {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 50),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: locale(context).userAgreement,
          style: AppFonts.link,
          recognizer: _userAgreementTapDetector,
        ),
      ),
    );
  }

  Widget get _form {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _label,
          _input,
          if (_error != null) _errorString,
          _button,
          if (_waitingForSms) _timerString,
          _space,
          _userAgreement,
        ],
      ),
    );
  }

  Widget get _body {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: _lock,
        ),
        Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 3 -
                  (_waitingForSms ? 24 : 0),
            ),
            child: _form),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        backgroundColor: AppColors.whiteBg,
        resizeToAvoidBottomInset: false,
        appBar: _appBar,
        extendBodyBehindAppBar: true,
        body: _body,
      ),
    );
  }
}
