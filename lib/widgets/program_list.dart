import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'circle.dart';
import '../models.dart';
import '../theme.dart';


class ProgramList extends StatelessWidget {
  final List<Program> program;
  final void Function(Program program) action;

  ProgramList({
    Key key,
    @required this.program,
    this.action,
  }): super(key: key);

  Widget get _dot {
    return Padding(
      padding: EdgeInsets.fromLTRB(1, 6, 1, 1),
      child: Circle.dot(
        radius: 4,
        color: AppColorsV2.red,
      ),
    );
  }

  Widget _time(String time, TextStyle font) {
    return  SizedBox(
      width: 47,
      child: Text(
        time,
        style: font,
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _title(String text, TextStyle font) {
    return Padding(
      padding: EdgeInsets.only(left: 6),
      child: Text(
        text,
        style: font,
      ),
    );
  }

  Widget _action(Program program) {
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: IconButton(
        icon: AppIconsV2.more,
        onPressed: () => action(program),
        constraints: BoxConstraints(),
        padding: EdgeInsets.zero,
        iconSize: 20,
      ),
    );
  }

  Widget _programTile(Program program, int id) {
    TextStyle font = id > 1 ? AppFontsV2.program
        : id < 1 ? AppFontsV2.programMute
        : AppFontsV2.programLive;
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          id == 1 ? _dot : SizedBox(width: 10),
          _time(program.startTime, font),
          Expanded(
            child: _title(program.title, font),
          ),
          action == null || id < 2
              ? SizedBox(width: 36)
              : _action(program),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int id = 0;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: program.map<Widget>((item) {
            Widget tile = item == null
                ? Container()
                : _programTile(item, id);
            id++;
            return tile;
          }).toList(),
        ),
      ),
    );
  }
}
