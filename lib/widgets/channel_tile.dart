import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import 'channel_logo.dart';


class ChannelAction {
  final void Function() action;
  final Widget icon;

  ChannelAction({
    @required this.action,
    @required this.icon,
  });
}


class ChannelTile extends StatelessWidget {
  final Channel channel;
  final void Function() onTap;
  final List<ChannelAction> actions;

  ChannelTile({
    Key key,
    @required this.channel,
    this.onTap,
    this.actions,
  }): super(key: key);

  bool get _hasActions => actions != null && actions.length > 0;

  Widget get _logo {
    return Padding(
      padding: _hasActions
          ? EdgeInsets.fromLTRB(0, 0, 16, 28)
          : EdgeInsets.fromLTRB(0, 0, 16, 8),
      child: ChannelLogo(
        size: _hasActions ? LogoSize.small : LogoSize.large,
        channel: channel,
      ),
    );
  }

  Widget get _title {
    return Text(
      channel.title,
      style: AppFontsV2.itemTitle,
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
        height: _hasActions ? 77 : 91,
        child: Padding(
          padding: _hasActions
              ? EdgeInsets.fromLTRB(0, 0, 50, 12)
              : EdgeInsets.fromLTRB(0, 0, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: _hasActions
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              _title,
              _program,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _actions {
    int id = 0;
    return  Column(
        mainAxisSize: MainAxisSize.min,
        children: actions.map<Widget>((action) {
          Widget result = IconButton(
            constraints: BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: action.icon,
            onPressed: action.action,
          );
          if(id > 0) result = Padding(
            padding: EdgeInsets.only(top: 10),
            child: result,
          );
          id += 1;
          return result;
        }).toList(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      children: [
       _logo,
        Expanded(
          child: _texts,
        ),
      ],
    );
    if(onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    if(_hasActions) {
      content = Stack(
        children: [
          content,
          Positioned(
            child: _actions,
            top: 0,
            right: 16,
          ),
        ],
      );
    }
    return PreferredSize(
      preferredSize: Size(double.infinity, _hasActions ? 77 : 91),
      child: content,
    ) ;
  }
}
