import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import 'channel_logo.dart';


class ChannelTile extends StatefulWidget {
  final Channel channel;

  ChannelTile({Key key, @required this.channel}): super(key: key);

  @override
  _ChannelTileState createState() => _ChannelTileState();
}

class _ChannelTileState extends State<ChannelTile> {
  Widget get _title {
    return Text(
      widget.channel.title,
      style: AppFontsV2.itemTitle,
    );
  }

  Widget get _program {
    return FutureBuilder(
      future: widget.channel.currentProgram,
      builder: (BuildContext context, AsyncSnapshot<Program> snapshot) {
        return Text(
          snapshot.data == null ? '' : snapshot.data.title,
          style: AppFonts.programName,
          maxLines: 2,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 16, 8),
            child: ChannelLogo(channel: widget.channel),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColorsV2.decorativeGray),
                )
              ),
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _title,
                    Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: _program,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      preferredSize: Size(double.infinity, 91),
    ) ;
  }
}

