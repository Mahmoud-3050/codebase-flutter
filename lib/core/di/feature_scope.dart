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
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final GetIt sl = ServiceLocator.instance;
    if (sl.hasScope(widget.scopeName)) {
      unawaited(_replaceScope());
      return;
    }
    _register(sl);
    _ready = true;
  }

  Future<void> _replaceScope() async {
    final GetIt sl = ServiceLocator.instance;
    if (sl.hasScope(widget.scopeName)) {
      await sl.dropScope(widget.scopeName);
    }
    if (!mounted) {
      return;
    }
    _register(sl);
    setState(() => _ready = true);
  }

  void _register(GetIt sl) {
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
    if (!_ready) {
      return const SizedBox.shrink();
    }
    return widget.child;
  }
}
