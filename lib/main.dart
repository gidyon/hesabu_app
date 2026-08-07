import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hesabu_app/core/theme/app_theme.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/router/app_router.dart';
import 'package:hesabu_app/core/network/api_client.dart';
import 'package:hesabu_app/core/network/auth_local_data_source.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:hesabu_app/features/auth/data/auth_repository_impl.dart';
import 'package:hesabu_app/features/auth/data/auth_remote_data_source.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/features/groups/data/groups_repository_impl.dart';
import 'package:hesabu_app/features/groups/data/groups_remote_data_source.dart';
import 'package:hesabu_app/features/settings/domain/settings_repository.dart';
import 'package:hesabu_app/features/settings/data/settings_repository_impl.dart';
import 'package:hesabu_app/core/security/security_controller.dart';
import 'package:hesabu_app/features/activity/application/activity_provider.dart';

late ThemeController _themeController;
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final authLocalDataSource = AuthLocalDataSource(sharedPreferences: prefs);
  final apiClient = ApiClient(authLocalDataSource: authLocalDataSource);

  final authRemoteDataSource = AuthRemoteDataSource(apiClient: apiClient);
  final groupsRemoteDataSource = GroupsRemoteDataSource(apiClient: apiClient);

  _themeController = ThemeController(prefs);

  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );

  // Determine initial location
  String initialLocation = '/intro';
  if (authRepository.hasSeenOnboarding()) {
    if (authRepository.isSessionValid()) {
      initialLocation = '/home';
    } else {
      initialLocation = '/login';
    }
  }

  runApp(
    MyApp(
      authRepository: authRepository,
      initialLocation: initialLocation,
      groupsRepository: GroupsRepositoryImpl(
        remoteDataSource: groupsRemoteDataSource,
        localDataSource: authLocalDataSource,
      ),
      settingsRepository: SettingsRepositoryImpl(
        localDataSource: authLocalDataSource,
      ),
      activityProvider: ActivityProvider(prefs),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthRepository authRepository;
  final GroupsRepository groupsRepository;
  final SettingsRepository settingsRepository;
  final ActivityProvider activityProvider;
  final String initialLocation;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.groupsRepository,
    required this.settingsRepository,
    required this.activityProvider,
    required this.initialLocation,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(widget.initialLocation);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: widget.authRepository),
        Provider<GroupsRepository>.value(value: widget.groupsRepository),
        Provider<SettingsRepository>.value(value: widget.settingsRepository),
        ChangeNotifierProvider<ActivityProvider>.value(
          value: widget.activityProvider,
        ),
        ChangeNotifierProvider(create: (_) => SecurityController()),
      ],
      child: InheritedThemeController(
        notifier: _themeController,
        child: ListenableBuilder(
          listenable: _themeController,
          builder: (context, _) {
            return MaterialApp.router(
              title: 'Hesabu Online',
              theme: AppTheme.themeFor(
                _themeController.accentColor,
                Brightness.light,
              ),
              darkTheme: AppTheme.themeFor(
                _themeController.accentColor,
                Brightness.dark,
              ),
              themeMode: _themeController.themeMode,
              routerConfig: _router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
