library cmodal;

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

part 'c_modal_controller.dart';
part 'c_modal_state_changer.dart';
part 'c_enums.dart';

/// displays modal on top of your page widget.
///
/// Wrap around your page widget to use.
class CModal extends StatefulWidget {
  /// this holds the page Widget the modal displays on top.
  final Widget child;

  /// this holds a custom loading indicator.
  final Widget? loadingIndicator;

  /// The modal controller.
  ///
  /// Controls the state of the modal.
  final CModalController controller;

  /// Builds your custom modal.
  final Widget? Function(BuildContext, CModalState)? builder;

  const CModal({
    required this.child,
    required this.controller,
    this.builder,
    this.loadingIndicator,
    Key? key,
  }) : super(key: key);

  @override
  State<CModal> createState() => _CModalState();
}

class _CModalState extends State<CModal> {
  final List<Widget> _widgetChildren = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // if modal is not displayed, then can pop freely.
        if (widget.controller._state == CModalState.none) {
          return true;
        }
        // else
        // calls user defined on back press function.
        widget.controller._onBackPress?.call();

        // handle to dismiss when back is pressed.
        if (widget.controller._dismissOnBackPress == true) {
          widget.controller.dismissModal();
          return false;
        }

        // handle to pop when back is pressed.
        if (widget.controller._popOnBackPress == true) {
          return true;
        }

        return false;
      },
      child: ValueListenableBuilder(
        valueListenable: widget.controller._notify,
        builder: (BuildContext context, CModalState cState, _) {
          _widgetChildren.clear();

          // expose the context through the controller
          widget.controller.context = context;

          // first add the parent display
          // meant to always stay behind modal and modal background
          _widgetChildren.add(widget.child);

          // if to display modalDisplay
          if (cState != CModalState.none) {
            // the keys are used for testing.
            _addModalBackGroundWidget(key: const ValueKey("modalBackground"));

            // sets the modal display
            _addModalDisplayWidget(
                key: const ValueKey("modalWidget"), cState: cState);
          }

          return Scaffold(
            body: Stack(
              children: _widgetChildren,
            ),
          );
        },
      ),
    );
  }

  _addModalDisplayWidget({required Key key, required CModalState cState}) {
    Widget modalDisplay = Container(
      key: key,
      child: _getModalDisplay(cState),
    );

    _widgetChildren.add(modalDisplay);
  }

  // determines the modal display based on modal state
  _getModalDisplay(CModalState cState) {
    return widget.controller._modalDisplay ??
        widget.builder?.call(context, cState) ??
        _defaultBuilder(cState);
  }

  // constructs the modal display
  // used to construct modal displays in default builder
  Widget _constructModalDisplayDefaults(CModalState modalState) {
    String text = modalState == CModalState.error
        ? widget.controller._displayMessage ?? "error!!"
        : modalState == CModalState.success
            ? widget.controller._displayMessage ?? "successful"
            : widget.controller._displayMessage ?? "Hey!";

    Color color = modalState == CModalState.error
        ? Colors.red
        : modalState == CModalState.success
            ? Colors.green
            : Colors.blue;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          alignment: Alignment.center,
          width: double.infinity,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ),
        ElevatedButton(
            onPressed: () {
              widget.controller._state = CModalState.none;
            },
            child: const Text(
              "OK",
              style: TextStyle(fontSize: 19),
            )),
      ],
    );
  }

  // in use when user does not provide a builder
  Widget? _defaultBuilder(CModalState cState) {
    if (cState == CModalState.loading) {
      return Center(child: _getLoadingIndicator);
    } else if (cState == CModalState.error) {
      return _constructModalDisplayDefaults(CModalState.error);
    } else if (cState == CModalState.success) {
      return _constructModalDisplayDefaults(CModalState.success);
    }

    return _constructModalDisplayDefaults(CModalState.custom1);
  }

  Widget get _getLoadingIndicator {
    return widget.loadingIndicator ?? const CircularProgressIndicator();
  }

  // wrap modal background in do opacity effect and add to widgetChildren
  void _addModalBackGroundWidget({required Key key}) {
    Widget modalBackGround = Container(
      key: key,
      child: widget.controller._fadeDuration == null
          ? _constructModalBackGround()
          : ModalBackGroundFadeTransition(
              fadeDuration: widget.controller._fadeDuration,
              child: _constructModalBackGround(),
            ),
    );

    _widgetChildren.add(modalBackGround);
  }

  // constructs the modal background with gesture detector and backdrop filter
  Widget _constructModalBackGround() {
    return GestureDetector(
      onTap: () {
        // dismiss when user clicks outside the display modal.
        if (widget.controller._dismissOnOutsideClick == true) {
          widget.controller.dismissModal();
        }

        // calls user defined function.
        widget.controller._onOutsideClick?.call();
      },

      // blurs the background
      child: Center(
          child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5.0,
          sigmaY: 5.0,
        ),
        child: Container(
          color: Colors.black.withOpacity(.7),
        ),
      )),
    );
  }
}

// Fades in the modal background.
class ModalBackGroundFadeTransition extends StatefulWidget {
  final Widget child;
  final Duration? fadeDuration;
  const ModalBackGroundFadeTransition(
      {Key? key, required this.child, this.fadeDuration})
      : super(key: key);

  @override
  _ModalBackGroundFadeTransitionState createState() =>
      _ModalBackGroundFadeTransitionState();
}

class _ModalBackGroundFadeTransitionState
    extends State<ModalBackGroundFadeTransition> {
  late ValueNotifier<double> opacityValue;

  @override
  void initState() {
    opacityValue = ValueNotifier(0);

    Future.delayed(Duration.zero, () {
      opacityValue.value = 1;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: opacityValue,
      builder: (_, value, __) {
        return AnimatedOpacity(
          duration: widget.fadeDuration ?? const Duration(milliseconds: 100),
          opacity: opacityValue.value,
          child: widget.child,
        );
      },
    );
  }
}
