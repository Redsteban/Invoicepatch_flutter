import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoicepatch_contractor/core/routing/app_router.dart';
import 'package:invoicepatch_contractor/core/services/auth_service.dart';
import 'package:invoicepatch_contractor/features/auth/bloc/auth_bloc.dart';
import 'package:invoicepatch_contractor/features/daily_logs/bloc/daily_log_bloc.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_bloc.dart';
import 'package:invoicepatch_contractor/shared/repositories/daily_log_repository.dart';
import 'package:invoicepatch_contractor/shared/repositories/client_repository.dart';
import 'package:invoicepatch_contractor/core/database/app_database.dart';

class InvoicePatchApp extends StatelessWidget {
  const InvoicePatchApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    final database = AppDatabase();
    
    // Define Swissborg palette
    const darkBlue = Color(0xFF191E29); // background
    const navyBlue = Color(0xFF132D46); // surface
    const emerald = Color(0xFF01C38D);  // primary/accent
    const gray = Color(0xFF696E79);     // gray
    const white = Color(0xFFFFFFFF);    // white

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (context) => MockAuthService(),
        ),
        RepositoryProvider<DailyLogRepository>(
          create: (context) => DailyLogRepository(
            dailyLogDao: database.dailyLogDao,
          ),
        ),
        RepositoryProvider<ClientRepository>(
          create: (context) => ClientRepository(
            clientDao: database.clientDao,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authService: context.read<AuthService>(),
            ),
          ),
          BlocProvider<DailyLogBloc>(
            create: (context) => DailyLogBloc(
              dailyLogRepository: context.read<DailyLogRepository>(),
            ),
          ),
          BlocProvider<ClientBloc>(
            create: (context) => ClientBloc(
              clientRepository: context.read<ClientRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'InvoicePatch',
          theme: ThemeData(
            fontFamily: 'Montserrat', // Use Montserrat or Inter as a TT Commons alternative
            primaryColor: emerald,
            scaffoldBackgroundColor: darkBlue,
            colorScheme: const ColorScheme(
              brightness: Brightness.dark,
              primary: emerald,
              onPrimary: white,
              secondary: navyBlue,
              onSecondary: white,
              error: Colors.red,
              onError: white,
              surface: navyBlue,
              onSurface: white,
              background: darkBlue,
              onBackground: white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: navyBlue,
              foregroundColor: emerald,
              elevation: 0,
              titleTextStyle: TextStyle(
                color: emerald,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
              iconTheme: IconThemeData(color: emerald),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: emerald,
                foregroundColor: white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: emerald,
                side: const BorderSide(color: emerald),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: gray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: emerald, width: 2),
              ),
              labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
              prefixIconColor: emerald,
              fillColor: navyBlue,
              filled: true,
            ),
            cardTheme: CardThemeData(
              color: navyBlue,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(color: white, fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
              headlineMedium: TextStyle(color: white, fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
              bodyLarge: TextStyle(color: white, fontFamily: 'Montserrat'),
              bodyMedium: TextStyle(color: gray, fontFamily: 'Montserrat'),
              labelLarge: TextStyle(color: emerald, fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            useMaterial3: true,
          ),
          routerConfig: appRouter.config(),
        ),
      ),
    );
  }
} 