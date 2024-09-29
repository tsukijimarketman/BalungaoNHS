import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pbma_portal/pages/dashboard.dart';
import 'package:pbma_portal/widgets/scroll_offset.dart';

class Launcher extends StatefulWidget {
  const Launcher({super.key});

  @override
  State<Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<Launcher> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_)=> DisplayOffset(ScrollOffset(scrollOffsetValue: 0)),
        child: const Dashboard());
  }
}