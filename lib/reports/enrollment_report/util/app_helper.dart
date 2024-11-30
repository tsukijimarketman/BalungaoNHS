import 'package:pbma_portal/reports/enrollment_report/presentation/resources/app_assets.dart';
import 'package:pbma_portal/reports/enrollment_report/urls.dart';

enum ChartType { line, bar, pie, scatter, radar }

extension ChartTypeExtension on ChartType {
  String get displayName => '$simpleName Chart';

  String get simpleName => switch (this) {
        ChartType.line => 'Line',
        ChartType.bar => 'Bar',
        ChartType.pie => 'Pie',
        ChartType.scatter => 'Scatter',
        ChartType.radar => 'Radar',
      };

  String get documentationUrl => Urls.getChartDocumentationUrl(this);

  String get assetIcon => AppAssets.getChartIcon(this);
}
