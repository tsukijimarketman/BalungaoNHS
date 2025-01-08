import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:balungao_nhs/pages/views/sections/desktop/desktop_view.dart';
import 'package:balungao_nhs/pages/views/sections/mobile/mobile_view.dart'; 

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 600;
  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isDesktop(context) ? DesktopView() : MobileView(), // Conditionally render the view
    );
  }
}
