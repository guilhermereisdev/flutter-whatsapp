import 'package:flutter/material.dart';
import 'package:flutter_whatsapp/model/conversa.dart';
import 'package:flutter_whatsapp/model/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp/route_generator.dart';

class AbaContatos extends StatefulWidget {
  const AbaContatos({Key? key}) : super(key: key);

  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  late String _idUsuarioLogado;
  late String _emailUsuarioLogado;

  Future<List<Usuario>> _recuperarContatos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection("usuarios").get();

    List<Usuario> listaUsuarios = [];

    for (DocumentSnapshot item in querySnapshot.docs) {
      var dados = item.data();
      if ((dados as dynamic)["email"] == _emailUsuarioLogado) continue;

      Usuario usuario = Usuario();
      usuario.idUsuario = item.id;
      usuario.email = (dados as dynamic)["email"];
      usuario.nome = (dados as dynamic)["nome"];
      usuario.urlImagem = (dados as dynamic)["urlImagem"];

      listaUsuarios.add(usuario);
    }

    return listaUsuarios;
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser!;
    _idUsuarioLogado = usuarioLogado.uid;
    _emailUsuarioLogado = usuarioLogado.email!;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: const [
                  Text("Carregando contatos"),
                  CircularProgressIndicator(),
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, indice) {
                List<Usuario>? listaItens = snapshot.data;
                Usuario usuario = listaItens![indice];
                return ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  leading: CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage: usuario.urlImagem != null
                        ? NetworkImage(usuario.urlImagem)
                        : null,
                  ),
                  title: Text(
                    usuario.nome,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, RouteGenerator.rotaMensagens,
                        arguments: usuario);
                  },
                );
              },
            );
            break;
          default:
            return Center(
              child: Column(
                children: const [
                  Text("Erro ao carregar a lista de contatos. Tente novamente.")
                ],
              ),
            );
        }
      },
    );
  }
}
