/// This library is displays a modal over a page Widget,
/// The page in question must be a child of the cModal widget.
///
/// [CModalController] is used when changing the state of the modal.
/// ```dart
///   CModalController cModalController = CModalController();
///   cModalController.state = CModalState.loading;
/// ```
///
/// [CModal] displays a modal on the page it wraps,
/// supply a Widget to its child property.
/// ```dart
///    CModal(
///      controller: CModalStateController()
///      child: PageWidget()
///    )
/// ```
///
/// [CModalState] represents the state of the modal.
///
/// [CModalStateChanger] holds the properties that describes the behaviour of
/// the next state and modal being changed to.
/// ```dart
///    CModalStateController cModalStateController = CModalStateController()
///      cModalStateController.changeModalState = CModalStateChanger(
///        state: CModalState.loading,
///     )
/// ```

library c_modal;

export 'package:c_modal/src/c_modal.dart';
