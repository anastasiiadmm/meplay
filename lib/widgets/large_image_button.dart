import 'package:flutter/material.dart';
import '../theme.dart';


class LargeImageButton extends StatelessWidget {
  final Widget image;
  final String text;
  final void Function() onTap;

  LargeImageButton({
    @required this.image,
    @required this.text,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.decorativeGray,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: image,
              ),
              Text(text, style: AppFonts.itemTitle,)
            ],
          ),
        ),
      ),
    );
  }
}
