// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppMainRouter extends RootStackRouter {
  _$AppMainRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
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
        child: const OnboardingScreen(),
      );
    },
    MainWrapperRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MainWrapperScreen(),
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
        child: ClientEntryScreen(
          key: args.key,
          existingClient: args.existingClient,
        ),
      );
    },
    DailyLogListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DailyLogListScreen(),
      );
    },
    DailyLogEntryRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DailyLogEntryScreen(),
      );
    },
    InvoiceSimulationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const InvoiceSimulationScreen(),
      );
    },
    InvoiceCreationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const InvoiceCreationScreen(),
      );
    },
    DummyPage.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DummyPage(),
      );
    },
  };
}

/// generated route for
/// [LoginScreen]
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

/// generated route for
/// [RegistrationScreen]
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

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingScreen();
    },
  );
}

/// generated route for
/// [MainWrapperScreen]
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

/// generated route for
/// [ClientListScreen]
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

/// generated route for
/// [ClientEntryScreen]
class ClientEntryRoute extends PageRouteInfo<ClientEntryRouteArgs> {
  ClientEntryRoute({
    Key? key,
    Client? existingClient,
    List<PageRouteInfo>? children,
  }) : super(
         ClientEntryRoute.name,
         args: ClientEntryRouteArgs(key: key, existingClient: existingClient),
         initialChildren: children,
       );

  static const String name = 'ClientEntryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ClientEntryRouteArgs>(
        orElse: () => const ClientEntryRouteArgs(),
      );
      return ClientEntryScreen(
        key: args.key,
        existingClient: args.existingClient,
      );
    },
  );
}

class ClientEntryRouteArgs {
  const ClientEntryRouteArgs({this.key, this.existingClient});

  final Key? key;

  final Client? existingClient;

  @override
  String toString() {
    return 'ClientEntryRouteArgs{key: $key, existingClient: $existingClient}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ClientEntryRouteArgs) return false;
    return key == other.key && existingClient == other.existingClient;
  }

  @override
  int get hashCode => key.hashCode ^ existingClient.hashCode;
}

/// generated route for
/// [DailyLogListScreen]
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

/// generated route for
/// [DailyLogEntryScreen]
class DailyLogEntryRoute extends PageRouteInfo<void> {
  const DailyLogEntryRoute({List<PageRouteInfo>? children})
    : super(DailyLogEntryRoute.name, initialChildren: children);

  static const String name = 'DailyLogEntryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DailyLogEntryScreen();
    },
  );
}

/// generated route for
/// [InvoiceSimulationScreen]
class InvoiceSimulationRoute extends PageRouteInfo<void> {
  const InvoiceSimulationRoute({List<PageRouteInfo>? children})
    : super(InvoiceSimulationRoute.name, initialChildren: children);

  static const String name = 'InvoiceSimulationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const InvoiceSimulationScreen();
    },
  );
}

/// generated route for
/// [InvoiceCreationScreen]
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

/// generated route for
/// [DummyPage]
class DummyPage extends PageRouteInfo<void> {
  const DummyPage({List<PageRouteInfo>? children})
    : super(DummyPage.name, initialChildren: children);

  static const String name = 'DummyPage';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DummyPage();
    },
  );
}