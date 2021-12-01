part of cmodal;

/// Changes the state of the modal while also setting properties of the
/// associated to that modal.
class CModalStateChanger {
  /// Custom modal display
  ///
  /// When set, this modal display would always be displayed,
  /// irrespective of the [state] assigned.
  Widget? displayedModal;

  /// When set to true, modal display is dismissed when modal background is
  /// tapped.
  bool? dismissOnOutsideClick;

  /// Sets state to the modal.
  ///
  /// Modals are displayed based on their state.
  ///
  /// Modals dispalys are associated to state from [CModal.builder]
  /// or by default if [CModal.builder] is not provided.
  CModalState state;

  /// Assigns message to be displayed for the current modal display if default
  /// modal display is being used.
  String? displayMessage;

  /// Called when modal display background is tapped.
  void Function()? onOutsideClick;

  /// Called when back button is tapped when modal display is visible.
  void Function()? onBackPress;

  /// Called when the modal display is dismissed.
  void Function()? onDismissModal;

  /// When set to true, Navigates back when modal display is visible and
  /// back is pressed.
  bool? popOnBackPress;

  /// When set to true, dismisses the modal display when back is pressed.
  bool? dismissOnBackPress;

  /// This Determines the modal display transition duration.
  Duration? fadeDuration;

  /// Constructs the state to be assigned to the modal with all
  /// properties associated with that modal.
  CModalStateChanger({
    required this.state,
    this.dismissOnOutsideClick = false,
    this.popOnBackPress = false,
    this.dismissOnBackPress = false,
    this.onBackPress,
    this.displayMessage,
    this.onOutsideClick,
    this.fadeDuration,
    this.displayedModal,
    this.onDismissModal,
  }) : assert((displayedModal != null && displayMessage == null) ||
            displayedModal == null);
}
