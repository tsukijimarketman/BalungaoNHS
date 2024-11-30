import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pbma_portal/pages/views/sections/desktop/contact_us.dart';
import 'package:pbma_portal/pages/views/sections/desktop/ribbon.dart';
import 'package:pbma_portal/pages/views/sections/mobile/contact_us_mobile.dart';
import 'package:pbma_portal/pages/views/sections/mobile/ribbon_mobile.dart';

class FooterMobile extends StatefulWidget {
  const FooterMobile({super.key});

  @override
  State<FooterMobile> createState() => _FooterMobileState();
}

class _FooterMobileState extends State<FooterMobile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              RibbonMobile(),
              ContactUsMobile()
            ],
          ),
    );
  }
}
