import 'package:flutter/material.dart';
import 'package:flutter_whatsapp/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_whatsapp/login.dart';
import 'package:flutter_whatsapp/route_generator.dart';

void main() async {
  // inicializa o firebase (obrigatório para qualquer recurso do firebase)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /*FirebaseFirestore.instance
      .collection("usuarios")
      .doc("001")
      .set({"nome": "Guilherme"});*/

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const Login(),
    theme: ThemeData(
      primaryColor: const Color(0xff075E54),
      accentColor: const Color(0xff25D366),
    ),
    initialRoute: RouteGenerator.rotaInicial,
    onGenerateRoute: RouteGenerator.generateRoute,
  ));
}
