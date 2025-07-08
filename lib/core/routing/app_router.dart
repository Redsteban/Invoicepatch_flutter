import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:invoicepatch_contractor/features/auth/presentation/screens/login_screen.dart';
import 'package:invoicepatch_contractor/features/auth/presentation/screens/registration_screen.dart';
import 'package:invoicepatch_contractor/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:invoicepatch_contractor/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:invoicepatch_contractor/features/daily_logs/presentation/screens/daily_log_entry_screen.dart';
import 'package:invoicepatch_contractor/features/daily_logs/presentation/screens/daily_log_list_screen.dart';
import 'package:invoicepatch_contractor/features/clients/presentation/screens/client_entry_screen.dart';
import 'package:invoicepatch_contractor/features/clients/presentation/screens/client_list_screen.dart';
import 'package:invoicepatch_contractor/shared/models/daily_log.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoicepatch_contractor/features/onboarding/bloc/onboarding_bloc.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    // Auth Routes
    AutoRoute(
      page: LoginRoute.page,
      path: '/login',
      initial: true,
    ),
    AutoRoute(
      page: RegistrationRoute.page,
      path: '/registration',
    ),
    AutoRoute(
      page: OnboardingRoute.page,
      path: '/onboarding',
    ),
    // Main App Routes
    AutoRoute(
      page: DashboardRoute.page,
      path: '/dashboard',
    ),
    // Daily Logs Routes
    AutoRoute(
      page: DailyLogListRoute.page,
      path: '/daily-logs',
    ),
    AutoRoute(
      page: DailyLogEntryRoute.page,
      path: '/daily-logs/add',
    ),
    AutoRoute(
      page: DailyLogEntryRoute.page,
      path: '/daily-logs/edit',
    ),
    // Client Routes
    AutoRoute(
      page: ClientListRoute.page,
      path: '/clients',
    ),
    AutoRoute(
      page: ClientEntryRoute.page,
      path: '/clients/add',
    ),
    AutoRoute(
      page: ClientEntryRoute.page,
      path: '/clients/edit',
    ),
  ];
}

// Page definitions
@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const LoginScreen();
}

@RoutePage()
class RegistrationPage extends StatelessWidget {
  const RegistrationPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const RegistrationScreen();
}

@RoutePage()
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => OnboardingBloc(),
    child: const OnboardingScreen(),
  );
}

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const DashboardScreen();
}

@RoutePage()
class DailyLogListPage extends StatelessWidget {
  const DailyLogListPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const DailyLogListScreen();
}

@RoutePage()
class DailyLogEntryPage extends StatelessWidget {
  final DailyLog? existingLog;
  final DateTime? initialDate;
  const DailyLogEntryPage({Key? key, this.existingLog, this.initialDate}) : super(key: key);
  @override
  Widget build(BuildContext context) => DailyLogEntryScreen(existingLog: existingLog, initialDate: initialDate);
}

@RoutePage()
class ClientListPage extends StatelessWidget {
  const ClientListPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const ClientListScreen();
}

@RoutePage()
class ClientEntryPage extends StatelessWidget {
  final Client? existingClient;
  const ClientEntryPage({Key? key, this.existingClient}) : super(key: key);
  @override
  Widget build(BuildContext context) => ClientEntryScreen(existingClient: existingClient);
} 