part of cmodal;

class CModalController {
  // The current context of the application when modal is visible.
  BuildContext? context;

  CModalController();

  // notifier for changing modal state
  final ValueNotifier<CModalState> _notify = ValueNotifier(CModalState.none);

  CModalState get _state => _notify.value;

  // The user defined modal to display.
  Widget? _modalDisplay;

  set _state(CModalState value) {
    _notify.value = value;
  }

  // message to display when default modal is displayed.
  String? _displayMessage;

  // called when modal background is clicked.
  void Function()? _onOutsideClick;

  // when set to true, modal is dismissed when modal background is clicked.
  bool? _dismissOnOutsideClick;

  // called when back is pressed when modal is visible.
  void Function()? _onBackPress;

  // called when modal is dismissed.
  void Function()? _onCloseModal;

  // when set to true, page is popped when back is pressed.
  bool? _popOnBackPress;

  // when set to true, modal is dismissed when back is pressed.
  bool? _dismissOnBackPress = true;

  // determines the duration as modal background is fadded in.
  Duration? _fadeDuration;

  /// Changes the state of the modal.
  ///
  /// Assigned [CModalStateChanger].
  ///
  /// See [CModalStateChanger] for options that can be provided when changing
  /// state of the modal.
  set changeModalState(CModalStateChanger cModalStateChanger) {
    //if cmodalStateChange state is none then should not set onCloseModal
    // function.
    assert((cModalStateChanger.state == CModalState.none &&
            cModalStateChanger.onDismissModal == null) ||
        (cModalStateChanger.state != CModalState.none));

    _popOnBackPress = cModalStateChanger.popOnBackPress;
    _onBackPress = cModalStateChanger.onBackPress;
    _dismissOnBackPress = cModalStateChanger.dismissOnBackPress;
    _dismissOnOutsideClick = cModalStateChanger.dismissOnOutsideClick;
    _displayMessage = cModalStateChanger.displayMessage;
    _onOutsideClick = cModalStateChanger.onOutsideClick;
    _fadeDuration = cModalStateChanger.fadeDuration;
    _state = cModalStateChanger.state;
    _modalDisplay = cModalStateChanger.displayedModal;
    _onCloseModal = cModalStateChanger.onDismissModal ?? _onCloseModal;

    if (cModalStateChanger.state == CModalState.none) {
      _onCloseModal?.call();
      _onCloseModal = null;
    }
  }

  /// Dismisses the current modal that is displayed.
  dismissModal() {
    changeModalState = CModalStateChanger(state: CModalState.none);
  }
}
