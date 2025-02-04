import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balungao_nhs/pages/dashboard.dart';
import 'package:balungao_nhs/widgets/scroll_offset.dart';

class Launcher extends StatefulWidget {
  final bool scrollToFooter;
  const Launcher({super.key, required this.scrollToFooter});

  @override
  State<Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<Launcher> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_)=> DisplayOffset(ScrollOffset(scrollOffsetValue: 0)),
        child:  Dashboard(scrollToFooter: widget.scrollToFooter),);
  }
}