import 'package:auto_route/auto_route.dart';
import 'package:invoicepatch_contractor/features/auth/presentation/screens/login_screen.dart';
import 'package:invoicepatch_contractor/features/auth/presentation/screens/registration_screen.dart';
import 'package:invoicepatch_contractor/features/clients/presentation/screens/client_entry_screen.dart';
import 'package:invoicepatch_contractor/features/clients/presentation/screens/client_list_screen.dart';
import 'package:invoicepatch_contractor/features/daily_logs/presentation/screens/daily_log_entry_screen.dart';
import 'package:invoicepatch_contractor/features/daily_logs/presentation/screens/daily_log_list_screen.dart';
import 'package:invoicepatch_contractor/features/dashboard/presentation/screens/main_wrapper_screen.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/screens/invoice_creation_screen.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/screens/invoice_simulation_screen.dart';
import 'package:invoicepatch_contractor/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';
import 'package:invoicepatch_contractor/shared/models/daily_log.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppMainRouter extends _$AppMainRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, path: '/login', initial: true),
        AutoRoute(page: RegistrationRoute.page, path: '/register'),
        AutoRoute(page: OnboardingRoute.page, path: '/onboarding'),
        AutoRoute(
          page: MainWrapperRoute.page,
          path: '/main',
          children: [
            AutoRoute(page: ClientListRoute.page, path: 'clients'),
            AutoRoute(page: DailyLogListRoute.page, path: 'logs'),
            AutoRoute(page: InvoiceSimulationRoute.page, path: 'invoices'),
          ],
        ),
        AutoRoute(page: ClientEntryRoute.page, path: '/client-entry'),
        AutoRoute(page: DailyLogEntryRoute.page, path: '/log-entry'),
        AutoRoute(page: InvoiceCreationRoute.page, path: '/invoice-creation'),
      ];
} 