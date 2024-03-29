import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import 'channel_logo.dart';

class ChannelTile extends StatelessWidget {
  final Channel channel;
  final void Function() onTap;
  final bool showNumber;

  ChannelTile({
    Key key,
    @required this.channel,
    this.onTap,
    this.showNumber: true,
  }) : super(key: key);

  Widget get _logo {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: ChannelLogo(
        size: LogoSize.large,
        channel: channel,
      ),
    );
  }

  Widget get _title {
    return Text(
      showNumber ? channel.title : channel.name,
      style: AppFonts.itemTitle,
      maxLines: 1,
    );
  }

  Widget get _program {
    return FutureBuilder<Program>(
      future: channel.currentProgram,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            snapshot.data == null ? '' : snapshot.data.timeTitle,
            style: AppFonts.itemTextSecondary,
            maxLines: 2,
          ),
        );
      },
    );
  }

  Widget get _separator {
    return FutureBuilder<Program>(
      future: channel.currentProgram,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        Widget result = SizedBox(
          height: 1,
          width: double.infinity,
          child: ColoredBox(color: AppColors.decorativeGray),
        );
        if (snapshot.hasData) {
          Program program = snapshot.data;
          int length = program.end.difference(program.start).inMilliseconds;
          int left = program.end.difference(DateTime.now()).inMilliseconds;
          double factor = left / length;
          result = Stack(
            children: [
              result,
              SizedBox(
                height: 1,
                child: FractionallySizedBox(
                  widthFactor: factor,
                  child: ColoredBox(color: AppColors.purple),
                ),
              ),
            ],
          );
        }
        return result;
      },
    );
  }

  Widget get _texts {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 90,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _title,
                _program,
              ],
            ),
          ),
        ),
        _separator,
      ],
    );
  }

  void emptyCallback() {}

  Widget _wrapTap(Widget content) {
    // if(onTap == null) return content;
    return InkWell(
      onTap: onTap == null ? emptyCallback : onTap,
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(double.infinity, 91),
      child: _wrapTap(
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _logo,
              Expanded(
                child: _texts,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
