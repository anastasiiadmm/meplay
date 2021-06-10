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
  }): super(key: key);

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

  Widget get _texts {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.decorativeGray),
        ),
      ),
      child: SizedBox(
        height: 91,
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
    );
  }

  Widget _wrapTap(Widget content) {
    if(onTap == null) return content;
    return GestureDetector(
      onTap: onTap,
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
    ) ;
  }
}
