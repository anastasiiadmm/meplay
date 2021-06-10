import 'dart:io';

import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';


class SquareList extends StatelessWidget {
  final List<Channel> channels;
  final bool Function(Channel channel) filter;

  SquareList({
    Key key,
    @required this.channels,
    this.filter,
  }): super(key: key);

  List<Channel> get _filterChannels {
    if(filter == null) return channels;
    return channels.where(filter).toList();
  }

  Widget _placeholder(Channel channel) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: AppIcons.logoPlaceholder,
        ),
        ColoredBox(
          color: Color.fromRGBO(255, 255, 255, 0.6),
          child: Center(
            child: Text(
              channel.title,
              textAlign: TextAlign.center,
              style: AppFonts.placeholderTextLarge,
              maxLines: 3,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _logo(Channel channel) {
    return FutureBuilder<File>(
      future: channel.logo,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? Image.file(snapshot.data)
            : _placeholder(channel);
      },
    );
  }

  Widget _lock(Channel channel) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
        ),
        color: AppColors.overlay,
      ),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: AppIcons.lock,
        ),
      ),
    );
  }

  Widget _tile(Channel channel, BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: AppColors.white,
        child: InkWell(
          onTap: () => channel.open(context),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Center(
                  child: _logo(channel),
                ),
              ),
              if(channel.locked) Positioned(
                top: 0,
                right: 0,
                child: _lock(channel),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _row(int id, List<Channel> channels, BuildContext context) {
    int itemId = id * 3;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: _tile(channels[itemId], context),
        ),
        SizedBox(width: 1,),
        Expanded(
          child: (itemId) < channels.length - 1
              ? _tile(channels[id * 3 + 1], context)
              : Container(),
        ),
        SizedBox(width: 1,),
        Expanded(
          child: (itemId) < channels.length - 2
              ? _tile(channels[id * 3 + 2], context)
              : Container(),
        ),
      ],
    );
  }

  int _rowCount(itemCount) => itemCount % 3 == 0
      ? itemCount ~/ 3
      : (itemCount ~/ 3 + 1);

  @override
  Widget build(BuildContext context) {
    List<Channel> channels = _filterChannels;
    return ListView.separated(
      itemCount: _rowCount(channels.length),
      itemBuilder: (context, int id) =>  _row(id, channels, context),
      separatorBuilder: (context, int id) => SizedBox(height: 1,),
    );
  }
}
