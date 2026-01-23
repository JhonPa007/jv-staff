import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:app_jv_staff/src/features/auth/presentation/login_screen.dart';
import 'package:app_jv_staff/src/features/home/presentation/dashboard_screen.dart';
import 'package:app_jv_staff/src/features/appointments/presentation/appointment_screen.dart';
import 'package:app_jv_staff/src/features/appointments/presentation/appointment_detail_screen.dart';
import 'package:app_jv_staff/src/features/media/presentation/upload_evidence_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const AppointmentScreen(),
      ),
    ],
  );
}
