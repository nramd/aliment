import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aliment/features/screens/splash_screen.dart';
import 'package:aliment/features/screens/get_started_page.dart';
import 'package:aliment/features/screens/login_page.dart';
import 'package:aliment/features/screens/signup_page.dart';
import 'package:aliment/features/screens/main_screen.dart';
import 'package:aliment/features/screens/etalase_page.dart';
import 'package:aliment/features/screens/add_food_page.dart';
import 'package:aliment/features/screens/preview_food_page.dart';
import 'package:aliment/features/screens/food_detail_page.dart';
import 'package:aliment/features/screens/edit_food_page.dart';
import 'package:aliment/features/screens/notification_settings_page.dart';
import 'package:aliment/features/models/food_item_model.dart';
import 'package:aliment/features/screens/notification_list_page.dart';
import 'package:aliment/features/screens/category_page.dart';
import 'package:aliment/features/screens/article_detail_page.dart';
import 'package:aliment/features/screens/share_page.dart';
import 'package:aliment/features/screens/share_from_etalase_page.dart';
import 'package:aliment/features/screens/set_share_location_page.dart';
import 'package:aliment/features/models/food_item_model.dart';
import 'package:aliment/features/screens/shared_food_detail_page.dart';
import 'package:aliment/features/screens/request_queue_page.dart';
import 'package:aliment/features/screens/share_history_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash Screen
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) {
        return const NoTransitionPage(child: SplashScreen());
      },
    ),

    // Get Started Page
    GoRoute(
      path: '/getStarted',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const GetStarted(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
      },
    ),

    // Login Page
    GoRoute(
      path: '/loginPage',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
      },
    ),

    // Sign Up Page
    GoRoute(
      path: '/SignUpPage',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const SignUpPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
      },
    ),

    // Home (Main Screen with Bottom Navigation)
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),

    // Etalase Page
    GoRoute(
      path: '/etalase',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const EtalasePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),

    // Add Food Page
    GoRoute(
      path: '/addFood',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const AddFoodPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),

    // Preview Food Page
    GoRoute(
      path: '/previewFood',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final food = extra['food'] as FoodItemModel;
        final imageFile = extra['imageFile'] as File?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: PreviewFoodPage(food: food, imageFile: imageFile),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),

    // Food Detail Page
    GoRoute(
      path: '/foodDetail/:id',
      pageBuilder: (context, state) {
        final foodId = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: FoodDetailPage(foodId: foodId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),

    // Edit Food Page
    GoRoute(
      path: '/editFood/:id',
      pageBuilder: (context, state) {
        final foodId = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: EditFoodPage(foodId: foodId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),

    // Notification Settings Page - BARU
    GoRoute(
      path: '/notificationSettings',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationSettingsPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationListPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),
    // Category Page
    GoRoute(
      path: '/category/:name',
      pageBuilder: (context, state) {
        final categoryName = state.pathParameters['name']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: CategoryPage(categoryName: categoryName),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),

// Article Detail Page
    GoRoute(
      path: '/article/:id',
      pageBuilder: (context, state) {
        final articleId = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: ArticleDetailPage(articleId: articleId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),
    // Route untuk detail shared food
    GoRoute(
      path: '/sharedFood/:id',
      pageBuilder: (context, state) {
        final foodId = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: SharedFoodDetailPage(foodId: foodId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),

// Route untuk share dari etalase
    GoRoute(
      path: '/shareFromEtalase',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const ShareFromEtalasePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),

// Route untuk request queue
    GoRoute(
      path: '/requestQueue/:id',
      pageBuilder: (context, state) {
        final foodId = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: RequestQueuePage(sharedFoodId: foodId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),

// Route untuk history
    GoRoute(
      path: '/shareHistory',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const ShareHistoryPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),
    
    // Set location
    GoRoute(
      path: '/setShareLocation',
      pageBuilder: (context, state) {
        final food = state.extra as FoodItemModel;
        return CustomTransitionPage(
          key: state.pageKey,
          child: SetShareLocationPage(food: food),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),
  ],
);

class NoTransitionPage<T> extends CustomTransitionPage<T> {
  const NoTransitionPage({required super.child})
      : super(
          transitionsBuilder: _transitionsBuilder,
          transitionDuration: Duration.zero,
        );

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
