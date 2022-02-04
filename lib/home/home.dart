import 'package:flutter/material.dart';
import 'package:tabernaculodafe/home/widgets/webradio.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{

  @override
  Widget build(BuildContext context) {

    double sizeScreen = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Web Rádio')
        ),
        body: const WebRadio()
      ),
    ); 
  }
}