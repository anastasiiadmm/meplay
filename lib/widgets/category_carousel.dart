import 'package:flutter/material.dart';
import 'package:me_play/theme.dart';

import '../models.dart';

class CategoryCarousel extends StatelessWidget {
  final List<Genre> categories;
  final void Function(Genre genre) onItemTap;
  final int activeId;

  CategoryCarousel({
    Key key,
    @required this.categories,
    this.onItemTap,
    this.activeId: 0,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int id) {
          Genre genre = categories[id];
          return Padding(
            padding: id == 0
                ? EdgeInsets.only(right: 12, left: 16)
                : id == categories.length - 1
                    ? EdgeInsets.only(right: 16)
                    : EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                if (onItemTap != null) onItemTap(genre);
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: genre.id == activeId
                      ? AppColors.purple
                      : AppColors.decorativeGray,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SizedBox(
                  height: 34,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 4, 10, 6),
                    child: Text(
                      genre.localName(context),
                      style: AppFonts.itemTitle,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
