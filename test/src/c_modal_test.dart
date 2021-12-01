import 'package:c_modal/c_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {
  Function callFunctionOnPop;
  MockNavigatorObserver(this.callFunctionOnPop);

  @override
  void didPop(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    callFunctionOnPop();
    super.noSuchMethod(Invocation.method(#didPop, [route]));
  }
}

void main() {
  Widget constructCModal(CModalController cModalController) {
    return MaterialApp(
      home: Scaffold(
        body: CModal(
          controller: cModalController,
          child: Container(),
        ),
      ),
    );
  }

  group("cModal", () {
    testWidgets(
        "should dismiss modal when CModalController.dismissModal is called.",
        (WidgetTester tester) async {
      //Arrange
      CModalController cModalController = CModalController();
      Finder modalWidgetFinder = find.byKey(const ValueKey("modalWidget"));

      //Act
      await tester.pumpWidget(constructCModal(cModalController));
      cModalController.changeModalState =
          CModalStateChanger(state: CModalState.custom1);
      await tester.pumpAndSettle();
      expect(modalWidgetFinder, findsOneWidget);

      cModalController.dismissModal();
      await tester.pumpAndSettle();

      expect(modalWidgetFinder, findsNothing);
    });

    testWidgets("test builder property of cModal", (WidgetTester tester) async {
      //Arrange
      CModalController cModalController = CModalController();
      Finder modalWidgetFinder = find.byKey(const ValueKey("modalWidget"));
      Widget C1 = Container();
      Widget C2 = Container();
      Widget C3 = Container();
      Finder c1Finder = find.byWidget(C1);
      Finder c2Finder = find.byWidget(C2);
      Finder c3Finder = find.byWidget(C3);

      final cModal = MaterialApp(
        home: Scaffold(
          body: CModal(
            builder: (_, state) {
              if (state == CModalState.custom1) {
                return C1;
              }

              if (state == CModalState.custom2) {
                return C2;
              }

              if (state == CModalState.custom3) {
                return C3;
              }
            },
            controller: cModalController,
            child: Container(),
          ),
        ),
      );

      //Act and //Assert
      await tester.pumpWidget(cModal);

      cModalController.changeModalState =
          CModalStateChanger(state: CModalState.custom1);
      await tester.pumpAndSettle();
      expect(c1Finder, findsOneWidget);

      cModalController.changeModalState =
          CModalStateChanger(state: CModalState.custom2);
      await tester.pumpAndSettle();
      expect(c2Finder, findsOneWidget);

      cModalController.changeModalState =
          CModalStateChanger(state: CModalState.custom3);
      await tester.pumpAndSettle();
      expect(c3Finder, findsOneWidget);
    });

    testWidgets(
        "should show CircularProgressIndicator when state is set to loading.",
        (WidgetTester tester) async {
      //Arrange
      CModalController cModalController = CModalController();
      Finder modalWidgetFinder = find.byKey(const ValueKey("modalWidget"));
      Finder circularProgressIndicatorFinder = find.descendant(
        of: modalWidgetFinder,
        matching: find.byType(CircularProgressIndicator),
      );

      //Act
      await tester.pumpWidget(constructCModal(cModalController));

      cModalController.changeModalState =
          CModalStateChanger(state: CModalState.loading);
      await tester.pump();
      expect(circularProgressIndicatorFinder, findsOneWidget);
    });

    testWidgets(
        "should show display loadingWidget that is set when state is"
        " set to loading.", (WidgetTester tester) async {
      //Arrange
      CModalController cModalController = CModalController();
      Widget loadingWidget = const Text("loading");
      // Finder modalWidgetFinder = find.byKey(const ValueKey("modalWidget"));
      Finder loadingWidgetFinder = find.byWidget(loadingWidget);

      final cModal = MaterialApp(
        home: Scaffold(
          body: CModal(
            loadingIndicator: loadingWidget,
            controller: cModalController,
            child: Container(),
          ),
        ),
      );

      //Act
      await tester.pumpWidget(cModal);

      cModalController.changeModalState =
          CModalStateChanger(state: CModalState.loading);
      await tester.pump();

//Assert

      expect(loadingWidgetFinder, findsOneWidget);
    });
  });

  group(
    "CModalStateChanger",
    () {
      group("with navigation:", () {
        Future<void> setUpCModalWidget(
            CModalController cModalController, WidgetTester tester,
            {MockNavigatorObserver? mockObserver}) async {
          late BuildContext mContext;

          Widget c_modal = Scaffold(
            appBar: AppBar(),
            body: CModal(
              controller: cModalController,
              child: Container(),
            ),
          );

          Widget home = MaterialApp(
            navigatorObservers: mockObserver != null ? [mockObserver] : [],
            home: Scaffold(
              body: Builder(builder: (context) {
                mContext = context;
                return Container();
              }),
            ),
          );

          await tester.pumpWidget(home);
          Navigator.of(mContext)
              .push(MaterialPageRoute(builder: (route) => c_modal));
        }

        testWidgets(
          "should call onBackPress when back button is pressed",
          (WidgetTester tester) async {
            // Arrange
            bool onBackPress = false;
            CModalController cModalController = CModalController();

            // Act
            await setUpCModalWidget(cModalController, tester);
            await tester.pumpAndSettle();

            cModalController.changeModalState = CModalStateChanger(
              state: CModalState.custom1,
              onBackPress: () => onBackPress = true,
            );

            await tester.pumpAndSettle();
            await tester.pageBack();

            expect(onBackPress, true);

            // Assert
          },
        );

        testWidgets(
          "should dismiss modal when dismissOnBackPress is true and back button is pressed",
          (WidgetTester tester) async {
            // Arrange
            bool onBackPress = false;
            CModalController cModalController = CModalController();
            Finder modalWidget = find.byKey(const ValueKey("modalWidget"));

            // Act
            await setUpCModalWidget(cModalController, tester);
            await tester.pumpAndSettle();

            cModalController.changeModalState = CModalStateChanger(
                state: CModalState.custom1, dismissOnBackPress: true);

            await tester.pumpAndSettle();
            expect(modalWidget, findsOneWidget);

            await tester.pageBack();
            await tester.pumpAndSettle();

            expect(modalWidget, findsNothing);

            // Assert
          },
        );

        testWidgets(
          "should pop Page when modal display is visible and back button is pressed",
          (WidgetTester tester) async {
            // Arrange
            bool navigateBack = false;
            CModalController cModalController = CModalController();
            Finder modalWidget = find.byKey(const ValueKey("modalWidget"));
            MockNavigatorObserver mockObserver =
                MockNavigatorObserver(() => navigateBack = true);

            // Act
            await setUpCModalWidget(cModalController, tester,
                mockObserver: mockObserver);

            await tester.pumpAndSettle();

            cModalController.changeModalState = CModalStateChanger(
              state: CModalState.custom1,
              popOnBackPress: true,
            );

            await tester.pumpAndSettle();
            expect(modalWidget, findsOneWidget);

            await tester.pageBack();
            await tester.pumpAndSettle();

            expect(navigateBack, true);

            // Assert
          },
        );
      });

      testWidgets(
        "should display a modalWidget And modalBackground when state is set.",
        (WidgetTester tester) async {
          //Arrange
          CModalController cModalController = CModalController();

          Finder modalBackgroundFinder =
              find.byKey(const ValueKey("modalBackground"));

          Finder modalWidgetFinder = find.byKey(const ValueKey("modalWidget"));

          //Act
          await tester.pumpWidget(constructCModal(cModalController));
          cModalController.changeModalState =
              CModalStateChanger(state: CModalState.custom1);
          await tester.pumpAndSettle();

          //Assert
          expect(modalWidgetFinder, findsOneWidget);
          expect(modalBackgroundFinder, findsOneWidget);
        },
      );

      testWidgets(
        "should display a displayedModal as modalWidget when displayedModal is "
        "set.",
        (WidgetTester tester) async {
          //Arrange
          Widget displayedWidget = Container();
          Finder displayedWidgetFinder = find.byWidget(displayedWidget);

          CModalController cModalController = CModalController();

          //Act
          await tester.pumpWidget(constructCModal(cModalController));

          cModalController.changeModalState = CModalStateChanger(
            state: CModalState.custom1,
            displayedModal: displayedWidget,
          );
          await tester.pumpAndSettle();

          //Assert
          expect(displayedWidgetFinder, findsOneWidget);
        },
      );

      testWidgets(
        "should display displayMessage if displayMessage is set"
        "set.",
        (WidgetTester tester) async {
          //Arrange
          String modalMessage = "Hey i was displayed";
          Finder modalMessageFinder = find.text(modalMessage);

          CModalController cModalController = CModalController();

          //Act
          await tester.pumpWidget(constructCModal(cModalController));

          cModalController.changeModalState = CModalStateChanger(
            state: CModalState.custom1,
            displayMessage: modalMessage,
          );

          await tester.pumpAndSettle();

          //Assert
          expect(modalMessageFinder, findsOneWidget);
        },
      );

      testWidgets(
        "should dismiss modal if modalBackground is tapped",
        (WidgetTester tester) async {
          //Arrange
          Finder modalWidget = find.byKey(const ValueKey("modalWidget"));
          Finder modalBackground =
              find.byKey(const ValueKey("modalBackground"));
          CModalController cModalController = CModalController();

          //Act
          await tester.pumpWidget(constructCModal(cModalController));
          cModalController.changeModalState = CModalStateChanger(
            dismissOnOutsideClick: true,
            state: CModalState.custom1,
          );
          await tester.pumpAndSettle();
          await tester.tap(modalBackground);
          await tester.pumpAndSettle();

          //Assert
          expect(modalWidget, findsNothing);
          expect(modalBackground, findsNothing);
        },
      );

      testWidgets(
        "should call onOutSideClick if modalBackground is tapped",
        (WidgetTester tester) async {
          //Arrange
          bool onOutsideClick = false;
          Finder modalBackground =
              find.byKey(const ValueKey("modalBackground"));
          CModalController cModalController = CModalController();

          //Act
          await tester.pumpWidget(constructCModal(cModalController));
          cModalController.changeModalState = CModalStateChanger(
            onOutsideClick: () => onOutsideClick = true,
            state: CModalState.custom1,
          );
          await tester.pumpAndSettle();
          await tester.tap(modalBackground);
          await tester.pumpAndSettle();

          //Assert
          expect(onOutsideClick, true);
        },
      );

      testWidgets(
        "should call OnDismissModal if modal is dismissed",
        (WidgetTester tester) async {
          //Arrange
          CModalController cModalController = CModalController();
          Finder modalBackground =
              find.byKey(const ValueKey("modalBackground"));
          bool onDismissModalIsCalled = false;

          //Act
          await tester.pumpWidget(constructCModal(cModalController));

          cModalController.changeModalState = CModalStateChanger(
            dismissOnOutsideClick: true,
            state: CModalState.custom1,
            onDismissModal: () => onDismissModalIsCalled = true,
          );

          await tester.pumpAndSettle();
          await tester.tap(modalBackground);
          await tester.pumpAndSettle();

          //Assert
          expect(onDismissModalIsCalled, true);
        },
      );

      testWidgets(
        "should make sure opacityDuration is properly set",
        (WidgetTester tester) async {
          //Arrange

          CModalController cModalController = CModalController();
          Finder modalBackgroundFinder =
              find.byKey(const ValueKey("modalBackground"));

          Duration fadeDuration = const Duration(seconds: 1);

          Finder opacityFinder = find.descendant(
              of: modalBackgroundFinder,
              matching: find.byType(AnimatedOpacity));

          //Act

          await tester.pumpWidget(constructCModal(cModalController));
          cModalController.changeModalState = CModalStateChanger(
            state: CModalState.custom1,
            fadeDuration: fadeDuration,
          );

          await tester.pump();
          await tester.pumpAndSettle();
          Duration actualFadeDuration =
              tester.firstWidget<AnimatedOpacity>(opacityFinder).duration;

          //Assert
          expect(actualFadeDuration, fadeDuration);
        },
      );
    },
  );
}

// void main1() {
//   setUpCModal(CModalController cModalController,
//       {MockNavigatorObserver? mockObserver}) {
//     return MaterialApp(
//       navigatorObservers: mockObserver == null ? [] : [mockObserver],
//       home: CModal(child: Container(), controller: cModalController),
//     );
//   }

//   late CModalController cModalController;

//   setUp(() {
//     cModalController = CModalController();
//   });

//   group("c_modal", () {
//     testWidgets('should make modal visible when changeModalState is set',
//         (WidgetTester tester) async {
//       //Arrange

//       Widget cModal = setUpCModal(cModalController);

//       //Act
//       await tester.pumpWidget(cModal);
//       cModalController.changeModalState = CModalStateChanger(
//         state: CModalState.custom1,
//       );

//       await tester.pump();

//       expect(find.byKey(const ValueKey("modalWidget")), findsOneWidget);
//     });

//     testWidgets('should remain hidded when changeModalState is not set',
//         (WidgetTester tester) async {
//       //Arrange

//       Widget cModal = setUpCModal(cModalController);

//       //act
//       await tester.pumpWidget(cModal);

//       expect(find.byKey(const ValueKey("modalWidget")), findsNothing);
//     });
//   });

//   group("CModalStateChanger", () {
//     testWidgets(
//       "Should always display displayedModal when displayedModal is set",
//       (WidgetTester tester) async {
//         //Arrange

//         Widget cModal = setUpCModal(cModalController);
//         Widget displayedModal = Container();

//         //Act
//         await tester.pumpWidget(cModal);
//         cModalController.changeModalState = CModalStateChanger(
//           state: CModalState.custom1,
//           displayedModal: displayedModal,
//         );

//         await tester.pump();
//         //Assert

//         expect(find.byWidget(displayedModal), findsOneWidget);
//       },
//     );

//     testWidgets(
//         "Should dismiss modal display when modal background is tapped and "
//         "dismissOutsideClick is set to true", (WidgetTester tester) async {
//       //Arrange

//       Widget cModal = setUpCModal(cModalController);
//       Widget displayedModal = Container();
//       Finder modalBackgroundFinder =
//           find.byKey(const ValueKey("modalBackground"));

//       Finder modalWidgetFinder = find.byKey(const ValueKey("modalWidget"));

//       //Act
//       await tester.pumpWidget(cModal);
//       cModalController.changeModalState = CModalStateChanger(
//         state: CModalState.custom1,
//         displayedModal: displayedModal,
//         dismissOnOutsideClick: true,
//       );
//       await tester.pump();
//       expect(modalWidgetFinder, findsOneWidget);
//       await tester.tap(modalBackgroundFinder);
//       await tester.pump();
//       expect(modalWidgetFinder, findsNothing);

//       //Assert
//     }, skip: true);

//     testWidgets(
//       "Should display message if displayMessage is set ",
//       (WidgetTester tester) async {
//         //Arrange

//         const String displayMessage = "Hey I was displayed";
//         Finder displayMessageFinder = find.text(displayMessage);

//         Widget cModal = setUpCModal(cModalController);

//         Finder modalWidgetFinder = find.byKey(const ValueKey("modalWidget"));

//         //Act
//         await tester.pumpWidget(cModal);
//         cModalController.changeModalState = CModalStateChanger(
//           state: CModalState.custom1,
//           displayMessage: displayMessage,
//         );
//         await tester.pumpAndSettle();

//         //Assert
//         expect(modalWidgetFinder, findsOneWidget);
//         expect(displayMessageFinder, findsOneWidget);
//       },
//     );

//     testWidgets(
//       "test onDismissModal",
//       (WidgetTester tester) async {
//         //Arrange

//         Widget cModal = setUpCModal(cModalController);

//         Finder modalWidgetFinder = find.byKey(const ValueKey("modalWidget"));

//         bool modalIsDismissed = false;

//         //Act
//         await tester.pumpWidget(cModal);
//         cModalController.changeModalState = CModalStateChanger(
//           state: CModalState.custom1,
//           onDismissModal: () => modalIsDismissed = true,
//         );

//         await tester.pump();
//         expect(modalWidgetFinder, findsOneWidget);

//         cModalController.dismissModal();
//         await tester.pump();
//         //Assert
//         expect(modalIsDismissed, true);
//       },
//     );

//     testWidgets(
//       "test builder",
//       (WidgetTester tester) async {
//         Widget c1 = Container();
//         Widget c2 = Container();

//         Widget cModal = MaterialApp(
//           home: CModal(
//             child: Container(),
//             controller: cModalController,
//             builder: (_, state) {
//               if (state == CModalState.custom1) {
//                 return c1;
//               }
//               if (state == CModalState.custom2) {
//                 return c2;
//               }
//             },
//           ),
//         );

//         // Finder modalWidgetFinder = find.byKey(const ValueKey("modalWidget"));
//         Finder modalBackgroundFinder =
//             find.byKey(const ValueKey("modalBackground"));
//         find.byKey(const ValueKey("modalBackground"));

//         Finder c1Finder = find.byWidget(c1);
//         Finder c2Finder = find.byWidget(c2);

//         await tester.pumpWidget(cModal);

//         cModalController.changeModalState = CModalStateChanger(
//             state: CModalState.custom1,
//             fadeDuration: const Duration(seconds: 1));

//         await tester.pump();

//         expect(c1Finder, findsOneWidget);

//         cModalController.changeModalState = CModalStateChanger(
//             state: CModalState.custom2,
//             fadeDuration: const Duration(seconds: 1));

//         await tester.pump();

//         expect(c2Finder, findsOneWidget);
//       },
//     );

//     testWidgets(
//       "test loading",
//       (WidgetTester tester) async {
//         // Widget c1 = Container();
//         Widget loadingIndicator = const Text("loading");

//         Widget cModal = MaterialApp(
//           home: CModal(
//             child: Container(),
//             controller: cModalController,
//           ),
//         );

//         Finder modalWidget = find.byKey(const ValueKey("modalWidget"));

//         Finder loadingWidgetFinder = find.descendant(
//             of: modalWidget, matching: find.byType(CircularProgressIndicator));

//         await tester.pumpWidget(cModal);

//         cModalController.changeModalState = CModalStateChanger(
//           state: CModalState.loading,
//         );

//         await tester.pump();

//         expect(loadingWidgetFinder, findsOneWidget);
//       },
//     );

//     testWidgets(
//       "test opacity",
//       (WidgetTester tester) async {
//         Widget cModal = setUpCModal(cModalController);

//         // Finder modalWidgetFinder = find.byKey(const ValueKey("modalWidget"));
//         Finder modalBackgroundFinder =
//             find.byKey(const ValueKey("modalBackground"));

//         await tester.pumpWidget(cModal);

//         cModalController.changeModalState = CModalStateChanger(
//             state: CModalState.custom1,
//             fadeDuration: const Duration(seconds: 1));

//         await tester.pump();

//         var t = await tester.pumpAndSettle();

//         expect(modalBackgroundFinder, findsOneWidget);

//         var f = find.descendant(
//             of: modalBackgroundFinder, matching: find.byType(AnimatedOpacity));

//         Duration animationDuration =
//             tester.firstWidget<AnimatedOpacity>(f).duration;

//         expect(animationDuration, const Duration(seconds: 1));
//       },
//     );

//     testWidgets(
//       "back test",
//       (WidgetTester tester) async {
//         //Arrange

//         final MockNavigatorObserver mockObserver = MockNavigatorObserver();

//         // NavigatorObserver().didPop(route, previousRoute)
//         late BuildContext mContext;
//         final firstWidget = MaterialApp(
//           navigatorObservers: [mockObserver],
//           home: Scaffold(
//             appBar: AppBar(),
//             body: Builder(builder: (context) {
//               mContext = context;
//               return Container();
//             }),
//           ),
//         );

//         Widget cModal = Scaffold(
//             appBar: AppBar(),
//             body: CModal(controller: cModalController, child: Container()));

//         await tester.pumpWidget(firstWidget);

//         Navigator.of(mContext).push(MaterialPageRoute(builder: (_) => cModal));

//         await tester.pumpAndSettle();

//         bool backPressAcknowledge = false;

//         cModalController.changeModalState = CModalStateChanger(
//             popOnBackPress: true,
//             state: CModalState.custom1,
//             onBackPress: () {
//               backPressAcknowledge = true;
//             });

//         await tester.pumpAndSettle();

//         await tester.pageBack();

//         await tester.pumpAndSettle();

//         // Finder modalWidget = find.byKey(const ValueKey("modalWidget"));

//         // expect(backPressAcknowledge, true);
//         // expect(modalWidget, findsOneWidget);
//       },
//       skip: true,
//     );
//   });
// }
