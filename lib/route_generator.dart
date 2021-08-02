import 'package:flutter/material.dart';
import 'package:flutter_whatsapp/cadastro.dart';
import 'package:flutter_whatsapp/configuracoes.dart';
import 'package:flutter_whatsapp/home.dart';
import 'package:flutter_whatsapp/login.dart';

class RouteGenerator {
  static const String rotaInicial = "/";
  static const String rotaLogin = "/login";
  static const String rotaCadastro = "/cadastro";
  static const String rotaHome = "/home";
  static const String rotaConfiguracoes = "/configuracoes";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case rotaInicial:
        return MaterialPageRoute(builder: (_) => Login());
      case rotaLogin:
        return MaterialPageRoute(builder: (_) => Login());
      case rotaCadastro:
        return MaterialPageRoute(builder: (_) => Cadastro());
      case rotaHome:
        return MaterialPageRoute(builder: (_) => Home());
      case rotaConfiguracoes:
        return MaterialPageRoute(builder: (_) => Configuracoes());
      default:
        return _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text("Tela não encontrada")),
        body: const Center(child: Text("Tela não encontrada")),
      );
    });
  }
}
