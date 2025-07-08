// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    ClientEntryRoute.name: (routeData) {
      final args = routeData.argsAs<ClientEntryRouteArgs>(
          orElse: () => const ClientEntryRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ClientEntryPage(
          key: args.key,
          existingClient: args.existingClient,
        ),
      );
    },
    ClientListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ClientListPage(),
      );
    },
    DailyLogEntryRoute.name: (routeData) {
      final args = routeData.argsAs<DailyLogEntryRouteArgs>(
          orElse: () => const DailyLogEntryRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DailyLogEntryPage(
          key: args.key,
          existingLog: args.existingLog,
          initialDate: args.initialDate,
        ),
      );
    },
    DailyLogListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DailyLogListPage(),
      );
    },
    DashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DashboardPage(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginPage(),
      );
    },
    OnboardingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OnboardingPage(),
      );
    },
    RegistrationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RegistrationPage(),
      );
    },
  };
}

/// generated route for
/// [ClientEntryPage]
class ClientEntryRoute extends PageRouteInfo<ClientEntryRouteArgs> {
  ClientEntryRoute({
    Key? key,
    Client? existingClient,
    List<PageRouteInfo>? children,
  }) : super(
          ClientEntryRoute.name,
          args: ClientEntryRouteArgs(
            key: key,
            existingClient: existingClient,
          ),
          initialChildren: children,
        );

  static const String name = 'ClientEntryRoute';

  static const PageInfo<ClientEntryRouteArgs> page =
      PageInfo<ClientEntryRouteArgs>(name);
}

class ClientEntryRouteArgs {
  const ClientEntryRouteArgs({
    this.key,
    this.existingClient,
  });

  final Key? key;

  final Client? existingClient;

  @override
  String toString() {
    return 'ClientEntryRouteArgs{key: $key, existingClient: $existingClient}';
  }
}

/// generated route for
/// [ClientListPage]
class ClientListRoute extends PageRouteInfo<void> {
  const ClientListRoute({List<PageRouteInfo>? children})
      : super(
          ClientListRoute.name,
          initialChildren: children,
        );

  static const String name = 'ClientListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DailyLogEntryPage]
class DailyLogEntryRoute extends PageRouteInfo<DailyLogEntryRouteArgs> {
  DailyLogEntryRoute({
    Key? key,
    DailyLog? existingLog,
    DateTime? initialDate,
    List<PageRouteInfo>? children,
  }) : super(
          DailyLogEntryRoute.name,
          args: DailyLogEntryRouteArgs(
            key: key,
            existingLog: existingLog,
            initialDate: initialDate,
          ),
          initialChildren: children,
        );

  static const String name = 'DailyLogEntryRoute';

  static const PageInfo<DailyLogEntryRouteArgs> page =
      PageInfo<DailyLogEntryRouteArgs>(name);
}

class DailyLogEntryRouteArgs {
  const DailyLogEntryRouteArgs({
    this.key,
    this.existingLog,
    this.initialDate,
  });

  final Key? key;

  final DailyLog? existingLog;

  final DateTime? initialDate;

  @override
  String toString() {
    return 'DailyLogEntryRouteArgs{key: $key, existingLog: $existingLog, initialDate: $initialDate}';
  }
}

/// generated route for
/// [DailyLogListPage]
class DailyLogListRoute extends PageRouteInfo<void> {
  const DailyLogListRoute({List<PageRouteInfo>? children})
      : super(
          DailyLogListRoute.name,
          initialChildren: children,
        );

  static const String name = 'DailyLogListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DashboardPage]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OnboardingPage]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
      : super(
          OnboardingRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RegistrationPage]
class RegistrationRoute extends PageRouteInfo<void> {
  const RegistrationRoute({List<PageRouteInfo>? children})
      : super(
          RegistrationRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegistrationRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
