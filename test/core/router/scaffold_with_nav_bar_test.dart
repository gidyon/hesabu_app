import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/router/scaffold_with_nav_bar.dart';

void main() {
  testWidgets('switches shell branches without duplicating GlobalKeys', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home-test',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ScaffoldWithNavBar(navigationShell: navigationShell),
          branches: [
            _branch('/home-test', 'Home content'),
            _branch('/groups-test', 'Groups content'),
            _branch('/activity-test', 'Activity content'),
            _branch('/settings-test', 'Settings content'),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('Home content'), findsOneWidget);

    for (final tab in ['Groups', 'Activity', 'Settings', 'Home', 'Groups']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    expect(find.text('Groups content'), findsOneWidget);
  });
}

StatefulShellBranch _branch(String path, String label) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: path,
      builder: (context, state) => Center(child: Text(label)),
    ),
  ],
);
