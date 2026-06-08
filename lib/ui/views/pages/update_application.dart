import 'package:flutter/material.dart';


class UpdateApplication extends StatefulWidget {
  const UpdateApplication({super.key});

  @override
  State<UpdateApplication> createState() => _UpdateApplicationState();
}

class _UpdateApplicationState extends State<UpdateApplication> {
  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
      body:  Center(
        child: Text("Welcome to the Update Application Page"),
      ),
    );
  }
}