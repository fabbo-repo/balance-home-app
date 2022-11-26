import 'package:flutter/material.dart';

class FutureWidget<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) childCreation;

  const FutureWidget({
    required this.future,
    required this.childCreation, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasData) {
          return childCreation(snapshot.data as T);
        } else if (snapshot.hasError) {
          return errorWidget();
        } 
        return loadingWidget();
      },
    );
  }

  @visibleForTesting
  Widget errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
        ],
      ),
    );
  }

  @visibleForTesting
  Widget loadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}