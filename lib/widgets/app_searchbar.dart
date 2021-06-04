import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import 'app_toolbar.dart';
import '../utils/settings.dart';


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
  }): super(key: key);

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

  void _restoreSystemOverlays() {
    Timer(Duration(milliseconds: 1001), SystemChrome.restoreSystemUIOverlays);
  }

  void _openSearch() {
    setState(() { _search = true; });
  }

  void _hideSearch() {
    setState(() { _search = false; });
  }

  void _clearSearch() {
    widget.onSearchSubmit('');
    _controller.value = TextEditingValue.empty;
    FocusScope.of(context).unfocus();
  }

  void _toggleSearch() {
    if(_search) _hideSearch();
    else _openSearch();
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
              if(hasFocus) _restoreSystemOverlays();
            },
            child: TextFormField(
              keyboardType: TextInputType.text,
              style: AppFontsV2.search,
              controller: _controller,
              onFieldSubmitted: widget.onSearchSubmit,
              cursorColor: AppColorsV2.white,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 32,
                ),
                hintText: locale(context).searchText,
                hintStyle: AppFontsV2.searchPlaceholder,
                fillColor: AppColorsV2.blockBg,
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: AppIconsV2.searchInput,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: AppIconsV2.clear,
              onPressed: _clearSearch,
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get _actions {
    return (widget.actions ?? <Widget>[])..insert(
      0,
      IconButton(
        onPressed: _toggleSearch,
        icon: AppIconsV2.search,
        constraints: BoxConstraints(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _search ? WillPopScope(
      onWillPop: _willPop,
      child: AppBar(
        backgroundColor: AppColorsV2.item,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 50,
        toolbarHeight: widget.preferredSize.height,
        leading: IconButton(
          onPressed: _back,
          icon: AppIconsV2.arrowLeft,
        ),
        title: Padding(
          child: _input,
          padding: EdgeInsets.only(right: 15),
        ),
        titleSpacing: 0,
      ),
    ) : AppToolBar(
      title: widget.title,
      actions: _actions,
    );
  }
}
