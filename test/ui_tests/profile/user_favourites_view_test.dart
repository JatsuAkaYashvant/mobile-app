import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mobile_app/locator.dart';
import 'package:mobile_app/models/projects.dart';
import 'package:mobile_app/ui/views/base_view.dart';
import 'package:mobile_app/ui/views/profile/user_favourites_view.dart';
import 'package:mobile_app/ui/views/projects/components/project_card.dart';
import 'package:mobile_app/ui/views/projects/project_details_view.dart';
import 'package:mobile_app/viewmodels/profile/profile_viewmodel.dart';
import '../../setup/test_helpers.mocks.dart';
import '../../utils_tests/image_test_utils.dart';
import 'package:mobile_app/utils/router.dart';
import 'package:mobile_app/viewmodels/profile/user_favourites_viewmodel.dart';
import 'package:mobile_app/viewmodels/projects/project_details_viewmodel.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/gen_l10n/app_localizations.dart';

import '../../setup/test_data/mock_projects.dart';

void main() {
  group('UserFavouritesViewTest -', () {
    late MockNavigatorObserver mockObserver;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await setupLocator();
      locator.allowReassignment = true;
    });

    setUp(() => mockObserver = MockNavigatorObserver());

    Future<void> _pumpUserFavouritesView(WidgetTester tester) async {
      final _profileViewModel = MockProfileViewModel();
      locator.registerSingleton<ProfileViewModel>(_profileViewModel);

      var _userFavoritesViewModel = MockUserFavouritesViewModel();
      locator.registerSingleton<UserFavouritesViewModel>(
        _userFavoritesViewModel,
      );

      var projects = <Project>[];
      projects.add(Project.fromJson(mockProject));

      when(
        _userFavoritesViewModel.FETCH_USER_FAVOURITES,
      ).thenAnswer((_) => 'fetch_user_favorites');
      when(_userFavoritesViewModel.fetchUserFavourites()).thenReturn(null);
      when(_userFavoritesViewModel.isSuccess(any)).thenReturn(true);
      when(_userFavoritesViewModel.userFavourites).thenAnswer((_) => projects);
      when(
        _userFavoritesViewModel.previousUserFavouritesBatch,
      ).thenAnswer((_) => null);

      await tester.pumpWidget(
        GetMaterialApp(
          onGenerateRoute: CVRouter.generateRoute,
          navigatorObservers: [mockObserver],
          localizationsDelegates: [AppLocalizations.delegate],
          supportedLocales: AppLocalizations.supportedLocales,
          home: BaseView<ProfileViewModel>(
            builder: (context, model, child) {
              return const Scaffold(body: UserFavouritesView());
            },
          ),
        ),
      );

      verify(mockObserver.didPush(any, any));
    }

    testWidgets('finds Generic UserFavouritesView widgets', (
      WidgetTester tester,
    ) async {
      await provideMockedNetworkImages(() async {
        await _pumpUserFavouritesView(tester);
        await tester.pumpAndSettle();

        expect(find.byType(ProjectCard), findsOneWidget);
      });
    });

    testWidgets('Project Page is Pushed onTap View button', (
      WidgetTester tester,
    ) async {
      await provideMockedNetworkImages(() async {
        await _pumpUserFavouritesView(tester);
        await tester.pumpAndSettle();

        var projectDetailsViewModel = MockProjectDetailsViewModel();
        locator.registerSingleton<ProjectDetailsViewModel>(
          projectDetailsViewModel,
        );

        final _recievedProject = Project.fromJson(mockProject);
        when(
          projectDetailsViewModel.receivedProject,
        ).thenAnswer((_) => _recievedProject);
        when(projectDetailsViewModel.isLoggedIn).thenAnswer((_) => true);
        when(
          projectDetailsViewModel.isProjectStarred,
        ).thenAnswer((_) => _recievedProject.attributes.isStarred);
        when(projectDetailsViewModel.starCount).thenAnswer((_) => 0);
        when(
          projectDetailsViewModel.FETCH_PROJECT_DETAILS,
        ).thenAnswer((_) => 'fetch_project_details');
        when(projectDetailsViewModel.fetchProjectDetails(any)).thenReturn(null);
        when(projectDetailsViewModel.isSuccess(any)).thenReturn(false);

        expect(find.byType(ProjectCard), findsOneWidget);

        Widget widget = find.byType(ProjectCard).evaluate().first.widget;
        (widget as ProjectCard).onPressed();
        await tester.pumpAndSettle();

        verify(mockObserver.didPush(any, any));
        expect(find.byType(ProjectDetailsView), findsOneWidget);
      });
    });
  });
}
