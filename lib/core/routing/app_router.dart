import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoicepatch_contractor/features/auth/presentation/screens/login_screen.dart';
import 'package:invoicepatch_contractor/features/auth/presentation/screens/registration_screen.dart';
import 'package:invoicepatch_contractor/features/clients/presentation/screens/client_entry_screen.dart';
import 'package:invoicepatch_contractor/features/clients/presentation/screens/client_list_screen.dart';
import 'package:invoicepatch_contractor/features/daily_logs/presentation/screens/daily_log_entry_screen.dart';
import 'package:invoicepatch_contractor/features/daily_logs/presentation/screens/daily_log_list_screen.dart';
import 'package:invoicepatch_contractor/features/dashboard/presentation/screens/main_wrapper_screen.dart';
import 'package:invoicepatch_contractor/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/screens/invoice_creation_screen.dart';
import 'package:invoicepatch_contractor/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:invoicepatch_contractor/features/auth/presentation/screens/welcome_screen.dart';
import 'package:invoicepatch_contractor/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';
import 'package:invoicepatch_contractor/shared/models/daily_log.dart';

// Route definitions
class AppMainRouter extends RootStackRouter {
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
    AutoRoute(
      page: WelcomeRoute.page,
      path: '/welcome',
    ),
    // Main App Routes
    AutoRoute(
      page: MainWrapperRoute.page,
      path: '/main',
      children: [
        AutoRoute(page: DashboardRoute.page, path: 'dashboard'),
        AutoRoute(page: ClientListRoute.page, path: 'clients'),
        AutoRoute(page: DailyLogListRoute.page, path: 'logs'),
        AutoRoute(page: InvoiceCreationRoute.page, path: 'invoices'),
      ],
    ),
    // Daily Logs Routes
    AutoRoute(
      page: DailyLogListRoute.page,
      path: '/daily-logs',
    ),
    AutoRoute(
      page: DailyLogEntryRoute.page,
      path: '/daily-logs/entry',
    ),
    // Client Routes
    AutoRoute(
      page: ClientListRoute.page,
      path: '/clients',
    ),
    AutoRoute(
      page: ClientEntryRoute.page,
      path: '/clients/entry',
    ),
    // Invoice Routes
    AutoRoute(
      page: InvoiceCreationRoute.page,
      path: '/invoice-creation',
    ),
  ];

  @override
  final Map<String, dynamic Function(RouteData)> pagesMap = {
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    RegistrationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RegistrationScreen(),
      );
    },
    OnboardingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BlocProvider(
          create: (_) => OnboardingBloc(),
          child: const OnboardingScreen(),
        ),
      );
    },
    WelcomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const WelcomeScreen(),
      );
    },
    MainWrapperRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MainWrapperScreen(),
      );
    },
    DashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DashboardScreen(),
      );
    },
    ClientListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ClientListScreen(),
      );
    },
    ClientEntryRoute.name: (routeData) {
      final args = routeData.argsAs<ClientEntryRouteArgs>(
          orElse: () => const ClientEntryRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ClientEntryScreen(existingClient: args.existingClient),
      );
    },
    DailyLogListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DailyLogListScreen(),
      );
    },
    DailyLogEntryRoute.name: (routeData) {
      final args = routeData.argsAs<DailyLogEntryRouteArgs>(
          orElse: () => const DailyLogEntryRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DailyLogEntryScreen(
          existingLog: args.existingLog,
          initialDate: args.initialDate,
        ),
      );
    },
    InvoiceCreationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const InvoiceCreationScreen(),
      );
    },
  };
}

// Route Classes
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

class RegistrationRoute extends PageRouteInfo<void> {
  const RegistrationRoute({List<PageRouteInfo>? children})
    : super(RegistrationRoute.name, initialChildren: children);

  static const String name = 'RegistrationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegistrationScreen();
    },
  );
}

class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return BlocProvider(
        create: (_) => OnboardingBloc(),
        child: const OnboardingScreen(),
      );
    },
  );
}

class MainWrapperRoute extends PageRouteInfo<void> {
  const MainWrapperRoute({List<PageRouteInfo>? children})
    : super(MainWrapperRoute.name, initialChildren: children);

  static const String name = 'MainWrapperRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainWrapperScreen();
    },
  );
}

class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardScreen();
    },
  );
}

class ClientListRoute extends PageRouteInfo<void> {
  const ClientListRoute({List<PageRouteInfo>? children})
    : super(ClientListRoute.name, initialChildren: children);

  static const String name = 'ClientListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ClientListScreen();
    },
  );
}

class ClientEntryRoute extends PageRouteInfo<ClientEntryRouteArgs> {
  ClientEntryRoute({
    Client? existingClient,
    List<PageRouteInfo>? children,
  }) : super(
         ClientEntryRoute.name,
         args: ClientEntryRouteArgs(existingClient: existingClient),
         initialChildren: children,
       );

  static const String name = 'ClientEntryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ClientEntryRouteArgs>(
        orElse: () => const ClientEntryRouteArgs(),
      );
      return ClientEntryScreen(existingClient: args.existingClient);
    },
  );
}

class ClientEntryRouteArgs {
  const ClientEntryRouteArgs({this.existingClient});

  final Client? existingClient;

  @override
  String toString() {
    return 'ClientEntryRouteArgs{existingClient: $existingClient}';
  }
}

class DailyLogListRoute extends PageRouteInfo<void> {
  const DailyLogListRoute({List<PageRouteInfo>? children})
    : super(DailyLogListRoute.name, initialChildren: children);

  static const String name = 'DailyLogListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DailyLogListScreen();
    },
  );
}

class DailyLogEntryRoute extends PageRouteInfo<DailyLogEntryRouteArgs> {
  DailyLogEntryRoute({
    DailyLog? existingLog,
    DateTime? initialDate,
    List<PageRouteInfo>? children,
  }) : super(
         DailyLogEntryRoute.name,
         args: DailyLogEntryRouteArgs(existingLog: existingLog, initialDate: initialDate),
         initialChildren: children,
       );

  static const String name = 'DailyLogEntryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DailyLogEntryRouteArgs>(
        orElse: () => const DailyLogEntryRouteArgs(),
      );
      return DailyLogEntryScreen(
        existingLog: args.existingLog,
        initialDate: args.initialDate,
      );
    },
  );
}

class DailyLogEntryRouteArgs {
  const DailyLogEntryRouteArgs({this.existingLog, this.initialDate});

  final DailyLog? existingLog;
  final DateTime? initialDate;

  @override
  String toString() {
    return 'DailyLogEntryRouteArgs{existingLog: $existingLog, initialDate: $initialDate}';
  }
}


class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WelcomeScreen();
    },
  );
}

class InvoiceCreationRoute extends PageRouteInfo<void> {
  const InvoiceCreationRoute({List<PageRouteInfo>? children})
    : super(InvoiceCreationRoute.name, initialChildren: children);

  static const String name = 'InvoiceCreationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const InvoiceCreationScreen();
    },
  );
}