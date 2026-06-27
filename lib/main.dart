import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_colors.dart';
import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/expense/presentation/bloc/expense_bloc.dart';
import 'features/expense/presentation/pages/root_shell.dart';
import 'features/scanner/presentation/bloc/scanner_bloc.dart';
import 'firebase_options.dart';
import 'services/widget_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID');
  await setupDi();
  await WidgetService.instance.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const PennyApp());
}

class PennyApp extends StatelessWidget {
  const PennyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExpenseBloc>(create: (_) => sl<ExpenseBloc>()),
        BlocProvider<DashboardBloc>(create: (_) => sl<DashboardBloc>()),
        BlocProvider<ScannerBloc>(create: (_) => sl<ScannerBloc>()),
      ],
      child: MaterialApp(
        title: 'Penny',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _Bootstrap(),
      ),
    );
  }
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    OnboardingPage.shouldShow().then((value) {
      if (mounted) setState(() => _showOnboarding = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_showOnboarding!) {
      return OnboardingPage(
        onDone: () => setState(() => _showOnboarding = false),
      );
    }
    return const RootShell();
  }
}
