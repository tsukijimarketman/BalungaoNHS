
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:balungao_nhs/reports/enrollment_report/presentation/pages/home_page.dart';
import 'package:balungao_nhs/reports/enrollment_report/presentation/resources/app_colors.dart';
import 'package:balungao_nhs/reports/enrollment_report/util/app_helper.dart';

final appRouterConfig = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Container(color: AppColors.pageBackground),
      redirect: (context, state) {
        return '/${ChartType.values.first.name}';
      },
    ),
    ...ChartType.values.map(
      (ChartType chartType) => GoRoute(
        path: '/${chartType.name}',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            MaterialPage<void>(
          /// We set a key for HomePage to prevent recreate it
          /// when user choose a new chart type to show
          key: const ValueKey('home_page'),
          child: HomePage(showingChartType: chartType),
        ),
      ),
    ),
    GoRoute(
      path: '/:any',
      builder: (context, state) => Container(color: AppColors.pageBackground),
      redirect: (context, state) {
        // Unsupported path, we redirect it to /, which redirects it to /line
        return '/';
      },
    ),
  ],
);
