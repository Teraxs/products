import 'package:flutter/material.dart';
import 'package:products_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class CheckAuthScreen extends StatelessWidget {
  const CheckAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: authService.readToken(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData) return const Text('wait');

            // if (snapshot.data == ''){

            // }
            Future.microtask(() {
              Navigator.of(context).pushReplacementNamed('login');
            });
            return Container();
          },
        ),
      ),
    );
  }
}
