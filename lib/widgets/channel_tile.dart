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
          style: AppFontsV2.itemTextSecondary,
          maxLines: 2,
        );
      },
    );
  }

  void _openChannel(BuildContext context, Channel channel) {
    String typeString = channel.type == ChannelType.tv ? 'tv' : 'radio';
    Navigator.of(context).pushNamed('/$typeString/${channel.id}');
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(double.infinity, 91),
      child: GestureDetector(
        onTap: () => _openChannel(context, widget.channel),
        child: Row(
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
                child: SizedBox(
                  height: 91,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 16, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _title,
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: _program,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ) ;
  }
}

