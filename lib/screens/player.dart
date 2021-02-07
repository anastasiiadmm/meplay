import 'dart:async';
import 'dart:convert';
import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

import '../utils/hls_video_cache.dart';
import '../video_player_fork/video_player.dart';
import 'base.dart';
import '../models.dart';
import '../theme.dart';


const double aspectRatio43 = 4/3;
const double aspectRatio169 = 16/9;


// 1 КТРК
// 3 Маданият
// 5 Ала Тоо
// 6 Спорт


const ktrk_program = '''6:58 Кыргыз Республикасынын Гимни
7:00 "Маанай"
7:10 "Суши и не только". Сериал. 18-я серия
7:30 "Карегимде Ата Журт: Чаткал". Даректүү фильм
8:08 "Үзүлбөгөн үзөңгү". Көркөм фильм ("Кыргызтелефильм")
9:05 "Алладин". Художественный фильм
11:07 "Глобус"
11:27 "Саякбай" ("Кыргызфильм")
12:00 "Маанай"
12:10 "Кошунаны тандабайт". Сериал
12:40 "Эрдин аты эрге тең" ("Кыргызтелефильм")
13:00 Новости
13:15 "Послание в бутылке". Художественный фильм
15:20 "Жүңгөгө сапар"
16:10 "Бизнес Өкүл Ата". Реалити-шоу
16:55 "Темир ооз комуз"
17:00 Күндарек
17:15 "Асылзат энелер баяны" ("Кыргызтелефильм")
17:35 "Аруузат"
18:20 "Байыркынын издери". Усундардын уюткусу
18:40 "Илим жана турмуш"
19:05 "Абаз"
19:55 "Телеклиника"
20:24 "Өмүр сызыгы". Камчыбек Букалаев
21:00 Итоги недели
22:05 "Кош келиңиздер"
23:10 "#One travel"
23:35 "Кайра жаралуу". Көркөм фильм
1:07 "Лев". Художественный фильм
3:00 Итоги недели
4:00 "Абаз". Телесынак
4:45 "Последняя битва". Художественный фильм
6:32 "Телеклиника"''';


const madaniyat_program = '''6:58 Кыргыз Республикасынын Гимни
7:00 "Алтын казына"
7:58 Концерт КР эл артисти С.Жумалиевдин чыгармачылык кечеси
9:34 Даректүү тасма "Кыргыз эстрадалык ансамбли"
10:00 "Жүңгөгө сапар"
10:30 Документальный фильм "Мифы эволюции: Живые воды"
11:29 "Акындардын айтышы"
12:11 Мировая классика "Любовь в Маастрихте" А.Рьё
14:30 Көркөм тасма "Махабат закымдары" (КР)
15:59 Концерт "Айтыштын ак жылдызы" И.Айдаркулова
18:30 "Улутман" "Укпайт деп, ушак айтпа" 1-көрсөтүү
19:05 "Кеттик тоого" Конорчек
19:35 "Улуу мурас" Чай демдөө
20:00 "Арноо концерти"
21:00 "Мен билген Раззаков" А.Какеев
21:15 Концерт Р.Рымбаева ырдайт
23:00 Художественный фильм "Доктор Лиза"
0:55 КР эл артисти С.Жумалиевдин чыгармачылык кечеси
2:31 Мировая классика "Любовь в Маастрихте" А.Рьё
4:46 Көркөм тасма "Махабат закымдары" (КР)
6:15 "Акындардын айтышы"''';


const ala_too_program = '''6:58 ГИМН
7:00 Күндарек
7:10 Ала-Тоо
7:55 Ролик
8:00 Атайын репортаж
8:10 "Иш илгери"
8:25 Атайын Репортаж
8:35 Күндарек
8:45 Дүйнөлүк жанылыктар
8:55 Ролики
9:00 Новости
9:10 "Иш илгери"
9:25 Кызыктар дүйнөсү
9:35 "Иш илгери"
9:50 ролик+валюта
10:00 Күндарек
10;10 Ролик
10:15 "Иш илгери"
10:30 Мировые новости
10:40 это интересно
10:50 Ролик +анонс
11:00 Новости
11:10 ролик
11:15 Кундарек
11:30 "Иш илгери"
11:45 Күндарек
11:55 Погода+ Курс валют+ролик
12:00 Мировые новости
12:10 Ролик
12:15 "Кеч эмес"
12:40 Ролик
12:45 Новости
12:55 Ролик
13:00 Новости
13:10 Погода+Курс валют+ Ролики
13:15 Еще не вечер
13:40 Кызыктар дүйнөсү
13:50 Ролик
14:00 Дүйнөлүк жаңылыктар
14:10 Погода+Курс валют+ Ролики
14:15 «Кеч эмес»
14:40 это интересно
14:50 Без комментариев
14:55 Ролик
15:00 Новости
15:10 Ролик
15:15 Еще не вечер
15:40 Кундарек
15:50 Без комментариев''';


const sport_program = '''7:00 Фитнес
7:10 Специальный выпуск История зимних Олимпийских игр
7:20 Спорт сыймыктары Магдалена Форсберг
7:30 Тайм-аут
7:45 Арена
8:30 Атайын чыгарылыш
8:40 Футбольные обзоры
9:00 Мундиалити
10:00 Волейбол КР Чемпионаты-21 (Live)
15:40 Эркин күрөш КР Чемпионаты-21
17:45 Бокс КР Чемпионаты-21 (Жаштар)
19:50 PRO Бокс
20:55 Футбол АПЛ 23-тур Тоттенхэм-Вест Бромвич (Live)
22:55 Футбол Серия А 21-тур Ювентус-Рома (Live)
1:00 Стимул
1:40 Футбол Серия А 21-тур Дженоа-Наполи (Live)
3:45 Мундиалити
4:45 Биатлон Кубок Мира-20\\21
6:58 Кыргыз Республикасынын Гимни''';


List<Map<String, String>> getProgram(Channel channel) {
  String program;
  if (channel.number == 1) program = ktrk_program;
  else if (channel.number == 3) program = madaniyat_program;
  else if (channel.number == 5) program = ala_too_program;
  else if (channel.number == 6) program = sport_program;
  else return null;
  return program.split('\n').map((e) {
    int firstSpace = e.indexOf(' ');
    return {
      'time': e.substring(0, firstSpace).trim(),
      'title': e.substring(firstSpace + 1).trim(),
    };
  }).toList();
}


class PlayerScreen extends StatefulWidget {
  final Channel channel;
  final void Function() toNext;
  final void Function() toPrev;

  PlayerScreen({
    Key key,
    @required this.channel,
    this.toNext,
    this.toPrev,
  }) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}


class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  VideoPlayerController _controller;
  double _aspectRatio = aspectRatio43;
  bool _controlsVisible = false;
  HLSVideoCache _cache;
  Timer _controlsTimer;
  static const Duration _controlsTimeout = Duration(seconds: 3);
  User _user;
  bool _forceFullscreen = false;

  @override
  void initState() {
    super.initState();
    _enableAllOrientations();
    _restoreUser();
    if (!widget.channel.locked) {
      _loadVideo(widget.channel);
    }
    WidgetsBinding.instance.addObserver(this);
    Wakelock.enable();
  }

  Future<void> _restoreUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('user')) {
      String userInfo = prefs.getString('user');
      _user =  User.fromJson(jsonDecode(userInfo));
    }
  }

  @override
  void dispose() {
    _disposeController();
    _clearCache();
    Wakelock.disable();
    WidgetsBinding.instance.removeObserver(this);
    _enablePortraitOnly();
    super.dispose();
  }

  void _enableAllOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _enablePortraitOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _enableLandscapeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _disposeController() {
    _controller?.dispose();
  }

  void _clearCache() {
    _cache?.clear();
  }

  Future<void> _loadVideo(Channel channel) async {
    _cache = HLSVideoCache(channel.url);
    await _cache.load();
    VideoPlayerController controller = VideoPlayerController.cache(_cache);
    await controller.initialize();
    setState(() {
      _controller = controller;
      _aspectRatio = controller.value.aspectRatio ?? _aspectRatio;
    });
    controller.play();
  }

  void _changeAspectRatio() {
    // TODO: show dialog to change ratio then
    // setState(() {
    //   _aspectRatio = ratio > 0 ? ratio : _controller.value.aspectRatio;
    // });
  }

  void _toPrev() {
    if(widget.toPrev != null) {
      Navigator.of(context).pop();
      widget.toPrev();
    }
  }

  void _toNext() {
    if(widget.toNext != null) {
      Navigator.of(context).pop();
      widget.toNext();
    }
  }

  void _togglePlay() {
    if (!_controlsVisible) {
      _toggleControls();
    }
    if (_controller != null) {
      if (_controller.value.isPlaying) {
        setState(() {
          _controller.pause();
        });
      } else {
        setState(() {
          _controller.play();
        });
      }
    }
  }

  void _showControls() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(_controlsTimeout, _hideControls);
    setState(() {
      _controlsVisible = true;
    });
  }

  void _hideControls() {
    _controlsTimer?.cancel();
    setState(() {
      _controlsVisible = false;
    });
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hideControls();
    } else {
      _showControls();
    }
  }

  // chromecast be here
  // void _chromecast() {
  //
  // }

  Widget get _scrollBar {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: _controller == null ? null : VideoProgressIndicator(
        _controller,
        allowScrubbing: true,
        colors: VideoProgressColors(
          backgroundColor: AppColors.transparentGray,
          playedColor: AppColors.gray5,
          bufferedColor: AppColors.gray40,
        ),
      ),
    );
  }

  bool get _fullscreen {
    return _forceFullscreen ||
      MediaQuery.of(context).orientation == Orientation.landscape;
  }

  void _swipeChannel(DragEndDetails details) {
    if(details.primaryVelocity > 0) {
      _toPrev();
    } else {
      _toNext();
    }
  }

  Widget get _player {
    if (_fullscreen) {
      return  GestureDetector(
        onTap: _toggleControls,
        onHorizontalDragEnd: _swipeChannel,
        child: Material(
          color: AppColors.black,
          child: Stack(
            children: [
              Center (
                child: _controller == null ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray5),
                  strokeWidth: 10,
                ) : AspectRatio(
                  aspectRatio: _aspectRatio,
                  child: VideoPlayer(
                    _controller,
                  ),
                ),
              ),
              _controls,
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _toggleControls,
        onHorizontalDragEnd: _swipeChannel,
        child: AspectRatio(
          aspectRatio: _aspectRatio,
          child: Material(
            color: AppColors.black,
            child: Stack(
              children: <Widget>[
                _controller == null ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray5),
                    strokeWidth: 10,
                  ),
                ) : VideoPlayer(
                  _controller,
                ),
                _controls,
              ],
            ),
          ),
        ),
      );
    }
  }

  void _goLive() {

  }

  Widget get _controls {
    return AnimatedOpacity(
      opacity: _controlsVisible ? 1.0 : 0,
      duration: Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.gradientTop),
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.gradientBottom),
          child: Column(
            children: <Widget>[
              Padding (
                padding: _fullscreen
                  ? EdgeInsets.fromLTRB(20, 15, 20, 0)
                  : EdgeInsets.fromLTRB(15, 10, 15, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: _fullscreen ? Text(
                          widget.channel.title,
                          style: AppFonts.screenTitle,
                        ) : null,
                      ),
                    ),
                    // chromecast be here
                    // IconButton(
                    //   icon: AppIcons.chromecast,
                    //   onPressed: _chromecast,
                    // ),
                    IconButton(
                      icon: AppIcons.settings,
                      onPressed: _changeAspectRatio,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: AppIcons.skipPrev,
                      onPressed: _toPrev,
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      width: 56,
                      margin: EdgeInsets.all(30),
                      child: _controller == null ? null : IconButton(
                        icon: _controller != null && _controller.value.isPlaying
                            ? AppIcons.pause
                            : AppIcons.play,
                        onPressed: _togglePlay,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    IconButton(
                      icon: AppIcons.skipNext,
                      onPressed: _toNext,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              Padding (
                padding: _fullscreen
                  ? EdgeInsets.fromLTRB(20, 0, 20, 15)
                  : EdgeInsets.fromLTRB(15, 0, 15, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Text(_timeDisplay, style: AppFonts.videoTimer,),
                    TextButton(
                      onPressed: _goLive,
                      child: Text('LIVE', style: AppFonts.screenTitle),
                    ),
                    Expanded(
                      child: _scrollBar,
                    ),
                    IconButton(
                      icon: _fullscreen ? AppIcons.smallScreen : AppIcons.fullScreen,
                      onPressed: _toggleFullScreen,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFullScreen() {
    if (_forceFullscreen) {
      _exitFullScreen();
    } else {
      _enterFullScreen();
    }
  }

  void _enterFullScreen() {
    _enableLandscapeOnly();
    setState(() {
      _forceFullscreen = true;
    });
  }

  void _exitFullScreen() {
    _enableAllOrientations();
    setState(() {
      _forceFullscreen = false;
    });
  }

  Future<bool> _willPop() async {
    if(_fullscreen) {
      _exitFullScreen();
      return false;
    }
    return true;
  }

  Widget get _appBar {
    return AppBar(
      backgroundColor: AppColors.megaPurple,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _back,
        icon: AppIcons.back,
      ),
      title: Text(widget.channel.title, style: AppFonts.screenTitle),
      centerTitle: true,
      actions: [
        IconButton(
          icon: AppIcons.favAdd,
          onPressed: () {NavItems.inDevelopment(context, title: 'Избранное');},
        ),
      ],
    );
  }

  void _back() {
    Navigator.of(context).pop();
  }

  void _onNavTap(int index) {
    Navigator.of(context).pop(index);
  }

  Widget get _bottomBar {
    return BottomNavigationBar(
      backgroundColor: AppColors.bottomBar,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: _onNavTap,
      currentIndex: 0,
      items: [
        BottomNavigationBarItem(
          icon: AppIcons.home,
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.star,
          label: 'Избранное',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.user,
          label: 'Профиль',
        ),
      ],
    );
  }

  void _login() {
    Navigator.of(context).pop(NavItems.login);
  }

  Widget get _program {
    List<Map> program = getProgram(widget.channel);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 22, horizontal: 0),
      child: program == null ? Text(
        'Программа для этого канала недоступна',
        style: AppFonts.currentProgramTitle,
        textAlign: TextAlign.center,
      ) : Stack(
        children: [
          ListView.builder(
            shrinkWrap: false,
            itemCount: program.length,
            itemExtent: 50,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 5),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      child: Text(
                        program[index]['time'],
                        style: index == 0 ? AppFonts.currentProgramTime : AppFonts.programTime,
                      )
                    ),
                    Expanded(
                      child: Text(
                        program[index]['title'],
                        style: index == 0 ? AppFonts.currentProgramTitle : AppFonts.programTitle,
                      )
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget get _title {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: AppColors.transparentBlack,
            )
          )
        ),
        child: Text(widget.channel.title, style: AppFonts.videoTitle),
      ),
    );
  }

  Widget get _lockInfo {
    // TODO: finish this
    return Container(
      decoration: BoxDecoration(
        color: AppColors.transparentGray,
        borderRadius: BorderRadius.circular(13),
      ),
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 27),
      padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _user == null
              ? 'Войдите, чтобы получить доступ к данному каналу'
              : "Для разблокировки канала подключите один из пакетов",
          ),
          TextButton(
            onPressed: _login,
            child: Text("Войти", style: AppFonts.channelLogin),
          )
        ],
      )
    );
  }

  Widget get _body {
    if(_fullscreen) return _player;
    List<Widget> children = [
      _player,
      _title,
      Expanded(child: _program),
    ];
    if(widget.channel.locked) {
      children.add(_lockInfo);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        backgroundColor: AppColors.white,
        extendBody: false,
        extendBodyBehindAppBar: false,
        appBar: _fullscreen ? null : _appBar,
        body: _body,
        bottomNavigationBar: _fullscreen ? null : _bottomBar,
      ),
    );
  }
}


// TODO: сделать кнопку live.
