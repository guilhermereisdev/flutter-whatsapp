import 'package:flutter/material.dart';
import 'package:flutter_whatsapp/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_whatsapp/login.dart';
import 'package:flutter_whatsapp/route_generator.dart';
import 'dart:io';

final ThemeData temaPadrao = ThemeData(
  primaryColor: const Color(0xff075E54),
  accentColor: const Color(0xff25D366),
);

final ThemeData temaIOS = ThemeData(
  primaryColor: Colors.grey[200],
  accentColor: const Color(0xff25D366),
);

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
    theme: Platform.isIOS ? temaIOS : temaPadrao,
    initialRoute: RouteGenerator.rotaInicial,
    onGenerateRoute: RouteGenerator.generateRoute,
  ));
}
