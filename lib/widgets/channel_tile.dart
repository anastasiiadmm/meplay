import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import 'channel_logo.dart';


class ChannelTile extends StatelessWidget {
  final Channel channel;
  final void Function(BuildContext context, Channel channel) onOpen;

  ChannelTile({
    Key key,
    @required this.channel,
    this.onOpen,
  }): super(key: key);

  Widget get _title {
    return Text(
      channel.title,
      style: AppFontsV2.itemTitle,
    );
  }

  Widget get _program {
    return FutureBuilder(
      future: channel.currentProgram,
      builder: (BuildContext context, AsyncSnapshot<Program> snapshot) {
        return Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            snapshot.data == null ? '' : snapshot.data.title,
            style: AppFontsV2.itemTextSecondary,
            maxLines: 2,
          ),
        );
      },
    );
  }

  Widget get _texts {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColorsV2.decorativeGray),
        ),
      ),
      child: SizedBox(
        height: 91,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 16, 8),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 16, 8),
          child: ChannelLogo(channel: channel),
        ),
        Expanded(
          child: _texts,
        ),
      ],
    );
    if(onOpen != null) {
      content = GestureDetector(
        onTap: () => onOpen(context, channel),
        child: content,
      );
    }
    return PreferredSize(
      preferredSize: Size(double.infinity, 91),
      child: content,
    ) ;
  }
}
