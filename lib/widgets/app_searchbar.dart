import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../channel.dart';
import '../theme.dart';
import '../utils/settings.dart';
import 'app_icon_button.dart';
import 'app_toolbar.dart';

// TODO: add bottom line on design

class AppSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final void Function(String text) onSearchSubmit;
  final List<Widget> actions;

  AppSearchBar({
    Key key,
    this.title,
    this.onSearchSubmit,
    this.actions,
  }) : super(key: key);

  @override
  _AppSearchBarState createState() => _AppSearchBarState();

  @override
  Size get preferredSize => Size(double.infinity, 44);
}

class _AppSearchBarState extends State<AppSearchBar> {
  TextEditingController _controller;
  bool _search = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _restoreSystemOverlays() async {
    if (!await isTv()) {
      Timer(Duration(milliseconds: 1001), SystemChrome.restoreSystemUIOverlays);
    }
  }

  void _openSearch() {
    setState(() {
      _search = true;
    });
  }

  void _hideSearch() {
    setState(() {
      _search = false;
    });
  }

  void _clearSearch() {
    widget.onSearchSubmit('');
    _controller.value = TextEditingValue.empty;
    FocusScope.of(context).unfocus();
  }

  void _toggleSearch() {
    if (_search)
      _hideSearch();
    else
      _openSearch();
  }

  void _back() {
    _clearSearch();
    _hideSearch();
  }

  Future<bool> _willPop() async {
    if (_search) {
      _back();
      return false;
    }
    return true;
  }

  Widget get _input {
    return SizedBox(
      height: 32,
      child: Stack(
        children: [
          Focus(
            onFocusChange: (hasFocus) {
              if (hasFocus) _restoreSystemOverlays();
            },
            child: TextFormField(
              keyboardType: TextInputType.text,
              style: AppFonts.search,
              controller: _controller,
              onFieldSubmitted: widget.onSearchSubmit,
              cursorColor: AppColors.white,
              textInputAction: TextInputAction.search,
              cursorHeight: 21,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 32,
                ),
                hintText: locale(context).searchText,
                hintStyle: AppFonts.searchPlaceholder,
                fillColor: AppColors.blockBg,
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.blockBg,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.itemFocus,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: AppIcons.searchInput,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: AppIconButton(
              icon: AppIcons.clear,
              onPressed: _clearSearch,
              padding: EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get _actions {
    List<Widget> actions = [
      AppIconButton(
        onPressed: _toggleSearch,
        icon: AppIcons.search,
        padding: EdgeInsets.all(5),
      ),
    ];
    if (widget.actions != null) actions.addAll(widget.actions);
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return _search
        ? WillPopScope(
            onWillPop: _willPop,
            child: AppBar(
              backgroundColor: AppColors.item,
              elevation: 0,
              automaticallyImplyLeading: false,
              leadingWidth: 50,
              toolbarHeight: widget.preferredSize.height,
              leading: AppIconButton(
                onPressed: _back,
                icon: AppIcons.arrowLeft,
                padding: EdgeInsets.all(8),
              ),
              title: Padding(
                child: _input,
                padding: EdgeInsets.only(right: 15),
              ),
              titleSpacing: 0,
              actions: [Container()],
            ),
          )
        : AppToolBar(
            title: widget.title,
            actions: _actions,
          );
  }
}
