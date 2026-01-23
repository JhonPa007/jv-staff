import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jv_staff/src/core/theme/app_theme.dart';
import 'package:app_jv_staff/src/shared/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: BarberStaffApp()));
}

class BarberStaffApp extends ConsumerWidget {
  const BarberStaffApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'BarberStaff',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
