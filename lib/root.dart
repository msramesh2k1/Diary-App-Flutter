import 'package:diary/home_page.dart';
import 'package:diary/login_screen.dart';
import 'package:diary/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    if (user == null) {        return const LoginScreen();
    } else {          return const HomePage();
    }
  }
}