import 'package:flutter/material.dart';
import 'rotation_loader.dart';


class FutureBlock<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget loader;
  final Size size;

  FutureBlock({
    Key key,
    @required this.future,
    @required this.builder,
    this.size,
    Widget loader,
  }): this.loader = loader ?? RotationLoader(),
    super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget result = Center(
      child: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? loader
              : builder(context, snapshot.data);
        },
      )
    );
    if(size != null) {
      result = SizedBox.fromSize(
        child: result,
        size: size,
      );
    }
    return result;
  }
}
