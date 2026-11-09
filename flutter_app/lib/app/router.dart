import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/strings.dart';
import '../core/widgets/amp_scaffold.dart';
import '../core/widgets/error_state.dart';
import '../features/admin/presentation/admin_desk_screen.dart';
import '../features/auth/application/app_role.dart';
import '../features/auth/application/session_controller.dart';
import '../features/auth/presentation/account_screen.dart';
import '../features/auth/presentation/role_landing_screen.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/common/presentation/notifications_screen.dart';
import '../features/consumer/presentation/booking_code_screen.dart';
import '../features/consumer/presentation/booking_screen.dart';
import '../features/consumer/presentation/bookings_screen.dart';
import '../features/consumer/presentation/charger_details_screen.dart';
import '../features/consumer/presentation/charging_history_screen.dart';
import '../features/consumer/presentation/charging_session_screen.dart';
import '../features/consumer/presentation/chat_screen.dart';
import '../features/consumer/presentation/discover_screen.dart';
import '../features/consumer/presentation/messages_screen.dart';
import '../features/consumer/presentation/navigation_screen.dart';
import '../features/consumer/presentation/report_screen.dart';
import '../features/consumer/presentation/safety_screen.dart';
import '../features/consumer/presentation/trip_planner_screen.dart';
import '../features/consumer/presentation/vehicle_form_screen.dart';
import '../features/consumer/presentation/vehicle_garage_screen.dart';
import '../features/gallery/component_gallery_screen.dart';
import '../features/host/presentation/host_station_form_screen.dart';
import '../features/host/presentation/host_workspace_screen.dart';
import 'navigation_shell.dart';

/// The route table and the one redirect that protects every private screen.
///
/// The session controller follows Supabase's auth stream, including a restored
/// encrypted session after a restart. The gallery route exists only in debug
/// builds and is the one exception to the guard.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<int> refresh = ValueNotifier<int>(0);
  ref.listen<SessionSnapshot>(sessionProvider, (
    SessionSnapshot? previous,
    SessionSnapshot next,
  ) {
    refresh.value += 1;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/start',
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (BuildContext context, GoRouterState state) {
      final bool signedIn = ref.read(sessionProvider).isSignedIn;
      final String location = state.matchedLocation;
      final bool onSignIn = location == '/sign-in';
      final bool onGallery = location == '/gallery' && kDebugMode;

      if (!signedIn && !onSignIn && !onGallery) {
        return '/sign-in';
      }
      if (signedIn && onSignIn) {
        return '/start';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/sign-in',
        builder: (BuildContext context, GoRouterState state) =>
            const SignInScreen(),
      ),
      GoRoute(
        path: '/start',
        builder: (BuildContext context, GoRouterState state) =>
            const RoleLandingScreen(),
      ),

      // Consumer branches. Detail, form and session screens stay outside this
      // shell so they cover the bar and back returns to the same branch.
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => RoleShell(
              navigationShell: navigationShell,
              role: AppRole.consumer,
            ),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (BuildContext context, GoRouterState state) =>
                    const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/trips',
                builder: (BuildContext context, GoRouterState state) =>
                    const TripPlannerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/bookings',
                builder: (BuildContext context, GoRouterState state) =>
                    const BookingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/messages',
                builder: (BuildContext context, GoRouterState state) =>
                    const MessagesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/account',
                builder: (BuildContext context, GoRouterState state) =>
                    const AccountScreen(),
              ),
            ],
          ),
        ],
      ),

      // Host branches. The existing workspace sections become the destinations.
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) =>
                RoleShell(navigationShell: navigationShell, role: AppRole.host),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/host/dashboard',
                builder: (BuildContext context, GoRouterState state) =>
                    const HostWorkspaceScreen(
                      section: HostWorkspaceSection.dashboard,
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/host/stations',
                builder: (BuildContext context, GoRouterState state) =>
                    const HostWorkspaceScreen(
                      section: HostWorkspaceSection.stations,
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/host/bookings',
                builder: (BuildContext context, GoRouterState state) =>
                    const HostWorkspaceScreen(
                      section: HostWorkspaceSection.bookings,
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/host/account',
                builder: (BuildContext context, GoRouterState state) =>
                    const AccountScreen(),
              ),
            ],
          ),
        ],
      ),

      // Admin branches.
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => RoleShell(
              navigationShell: navigationShell,
              role: AppRole.admin,
            ),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/admin/queue',
                builder: (BuildContext context, GoRouterState state) =>
                    const AdminDeskScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/admin/reports',
                builder: (BuildContext context, GoRouterState state) =>
                    const AdminDeskScreen(section: AdminDeskSection.reports),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/admin/account',
                builder: (BuildContext context, GoRouterState state) =>
                    const AccountScreen(),
              ),
            ],
          ),
        ],
      ),

      // Short links used by older screens still land on the role desk.
      GoRoute(path: '/host', redirect: (_, _) => '/host/dashboard'),
      GoRoute(path: '/admin', redirect: (_, _) => '/admin/queue'),

      // Pushed flows: these sit above the shell and have no tab bar.
      GoRoute(
        path: '/host/stations/new',
        builder: (BuildContext context, GoRouterState state) =>
            const HostStationFormScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (BuildContext context, GoRouterState state) =>
            const NotificationsScreen(),
      ),
      GoRoute(
        path: '/safety',
        builder: (BuildContext context, GoRouterState state) =>
            SafetyScreen(stationId: state.uri.queryParameters['stationId']),
      ),
      GoRoute(
        path: '/report',
        builder: (BuildContext context, GoRouterState state) {
          final Map<String, String> query = state.uri.queryParameters;
          return ReportScreen(
            stationId: query['stationId'],
            hostId: query['hostId'],
            sessionId: query['sessionId'],
            stationName: query['stationName'],
            hostMode: query['host'] == '1',
          );
        },
      ),
      GoRoute(
        path: '/vehicles',
        builder: (BuildContext context, GoRouterState state) =>
            const VehicleGarageScreen(),
      ),
      GoRoute(
        path: '/vehicles/new',
        builder: (BuildContext context, GoRouterState state) =>
            const VehicleFormScreen(),
      ),
      GoRoute(
        path: '/vehicles/:vehicleId',
        builder: (BuildContext context, GoRouterState state) =>
            VehicleFormScreen(vehicleId: state.pathParameters['vehicleId']),
      ),
      GoRoute(
        path: '/navigation',
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is! NavigationTrip) {
            return AmpScaffold(
              title: AmpStrings.navigationTitle,
              padded: true,
              body: const ErrorState(
                title: AmpStrings.routeNotFoundTitle,
                message: AmpStrings.routeNotFoundBody,
              ),
            );
          }
          return NavigationScreen(trip: extra);
        },
      ),
      GoRoute(
        path: '/sessions',
        builder: (BuildContext context, GoRouterState state) =>
            const ChargingHistoryScreen(),
      ),
      GoRoute(
        path: '/sessions/:reservationId',
        builder: (BuildContext context, GoRouterState state) =>
            ChargingSessionScreen(
              reservationId: state.pathParameters['reservationId']!,
            ),
      ),
      GoRoute(
        path: '/messages/:threadId',
        builder: (BuildContext context, GoRouterState state) =>
            ChatScreen(threadId: state.pathParameters['threadId']!),
      ),
      GoRoute(
        path: '/bookings/:reservationId',
        builder: (BuildContext context, GoRouterState state) =>
            BookingCodeScreen(
              reservationId: state.pathParameters['reservationId']!,
            ),
      ),
      GoRoute(
        path: '/book/:stationId',
        builder: (BuildContext context, GoRouterState state) =>
            BookingScreen(stationId: state.pathParameters['stationId']!),
      ),
      GoRoute(
        path: '/chargers/:stationId',
        builder: (BuildContext context, GoRouterState state) =>
            ChargerDetailsScreen(
              stationId: state.pathParameters['stationId']!,
              autoDirections: state.uri.queryParameters['directions'] == '1',
            ),
      ),
      if (kDebugMode)
        GoRoute(
          path: '/gallery',
          builder: (BuildContext context, GoRouterState state) =>
              const ComponentGalleryScreen(),
        ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return AmpScaffold(
        title: AmpStrings.routeNotFoundTitle,
        padded: true,
        body: const ErrorState(
          title: AmpStrings.routeNotFoundTitle,
          message: AmpStrings.routeNotFoundBody,
        ),
      );
    },
  );
});
