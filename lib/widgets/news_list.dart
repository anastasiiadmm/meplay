import 'package:flutter/material.dart';
import '../models.dart';
import 'news_tile.dart';


class NewsList extends StatelessWidget {
  final List<News> news;
  final void Function(News newsItem) onOpen;

  NewsList({
    Key key,
    @required this.news,
    this.onOpen,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    int id = 0;
    return ListView(
      children: news.map<Widget>((newsItem) {
        Widget tile = Padding(
          padding: id == 0
              ? EdgeInsets.symmetric(vertical: 12)
              : EdgeInsets.only(bottom: 12),
          child: NewsTile(
            newsItem: newsItem,
            onTap: () => onOpen(newsItem),
          ),
        );
        id++;
        return tile;
      }).toList(),
    );
  }
}
