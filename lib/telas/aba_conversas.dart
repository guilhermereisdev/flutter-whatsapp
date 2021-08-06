import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_whatsapp/model/conversa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp/model/usuario.dart';

import '../route_generator.dart';

class AbaConversas extends StatefulWidget {
  const AbaConversas({Key? key}) : super(key: key);

  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaConversas> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  late String _idUsuarioLogado;

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  /*Stream<QuerySnapshot>*/
  _adicionarListenerConversas() {
    final stream = db
        .collection("conversas")
        .doc(_idUsuarioLogado)
        .collection("ultima_conversa")
        .orderBy("data", descending: true)
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser as User;
    setState(() {
      _idUsuarioLogado = usuarioLogado.uid;
    });
    _adicionarListenerConversas();
  }

  @override
  void dispose() {
    super.dispose();
    //_controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: const [
                  Text("Carregando conversas"),
                  CircularProgressIndicator(),
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return const Text("Erro ao carregar dados");
            } else {
              QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
              if (querySnapshot.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "Não há mensagens",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: querySnapshot.docs.length,
                itemBuilder: (context, indice) {
                  List<DocumentSnapshot> conversas =
                      querySnapshot.docs.toList();
                  DocumentSnapshot item = conversas[indice];
                  String urlImagem = item["caminhoFoto"];
                  String tipo = item["tipoMensagem"];
                  String mensagem = item["mensagem"];
                  String nome = item["nome"];
                  String idDestinatario = item["idDestinatario"];

                  Usuario usuario = Usuario();
                  usuario.nome = nome;
                  usuario.urlImagem = urlImagem;
                  usuario.idUsuario = idDestinatario;

                  return ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          urlImagem != null ? NetworkImage(urlImagem) : null,
                    ),
                    title: Text(
                      nome,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      tipo == "texto" ? mensagem : "Imagem",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, RouteGenerator.rotaMensagens,
                          arguments: usuario);
                    },
                  );
                },
              );
            }
            break;
        }
      },
    );
  }
}
