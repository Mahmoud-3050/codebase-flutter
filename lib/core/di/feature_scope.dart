import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../injection_container.dart';

typedef FeatureRegistration = void Function(GetIt sl);

/// Pushes a named GetIt scope on enter, runs only the given registrations,
/// and drops the scope on exit.
class FeatureScope extends StatefulWidget {
  const FeatureScope({
    required this.scopeName,
    required this.registrations,
    required this.child,
    super.key,
  });

  final String scopeName;
  final List<FeatureRegistration> registrations;
  final Widget child;

  @override
  State<FeatureScope> createState() => _FeatureScopeState();
}

class _FeatureScopeState extends State<FeatureScope> {
  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();
    _ready = _init();
  }

  Future<void> _init() async {
    final sl = ServiceLocator.instance;
    if (sl.hasScope(widget.scopeName)) {
      await sl.dropScope(widget.scopeName);
    }
    sl.pushNewScope(scopeName: widget.scopeName);
    for (final FeatureRegistration register in widget.registrations) {
      register(sl);
    }
  }

  @override
  void dispose() {
    final sl = ServiceLocator.instance;
    if (sl.hasScope(widget.scopeName)) {
      unawaited(sl.dropScope(widget.scopeName));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState != .done) {
          return const SizedBox.shrink();
        }
        return widget.child;
      },
    );
  }
}
