import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp/model/mensagem.dart';

import 'model/usuario.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato, {Key? key}) : super(key: key);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  late String _idUsuarioLogado;
  late String _idUsuarioDestinatario;

  FirebaseFirestore db = FirebaseFirestore.instance;
  List<String> listaMensagens = [
    "Opa! Bão? Fiquei sabendo que o Galão vai jogar hoje e vai meter uns 3 gols só no primeiro tempo. É verdade?",
    "Bão e aí? Vai sim. Galão vai fazer dezoito gols nos três primeiros chutes ao gol.",
    "Bacana",
    "Então tá bão",
    "Top",
    "Topper",
    "Opa! Bão?",
    "Bão e aí?",
    "Bacana",
    "Então tá bão",
    "Top",
    "Topper",
  ];
  TextEditingController _controllerMensagem = TextEditingController();

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";

      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);
    }
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    await db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    _controllerMensagem.clear();
  }

  _enviarFoto() {}

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser as User;
    setState(() {

      _idUsuarioLogado = usuarioLogado.uid;

      _idUsuarioDestinatario = widget.contato.idUsuario;
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: false,
                keyboardType: TextInputType.text,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                  hintText: "",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  prefixIcon: IconButton(
                    onPressed: () {
                      _enviarFoto();
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Color(0xff075E54),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: const Color(0xff075E54),
            child: const Icon(Icons.send, color: Colors.white),
            mini: true,
            onPressed: () {
              _enviarMensagem();
            },
          ),
        ],
      ),
    );

    StreamBuilder<QuerySnapshot<Map<String, dynamic>>> retornaStream() {
      return StreamBuilder(
        // Listener que verifica se há alguma alteração nas mensagens
        stream: db
            .collection("mensagens")
            .doc(_idUsuarioLogado)
            .collection(_idUsuarioDestinatario)
            .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: const [
                    Text("Carregando mensagens"),
                    CircularProgressIndicator(),
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
              if (snapshot.hasError) {
                return const Expanded(
                  child: Text("Erro ao carregar dados"),
                );
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: querySnapshot.docs.length,
                    itemBuilder: (context, indice) {
                      // Recupera mensagens
                      List<DocumentSnapshot> mensagens =
                      querySnapshot.docs.toList();
                      DocumentSnapshot item = mensagens[indice];
                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.75;
                      // Define cores e alinhamentos
                      Alignment alinhamento = Alignment.centerRight;
                      Color cor = const Color(0xffD2FFA5);
                      if (_idUsuarioLogado != item["idUsuario"]) {
                        cor = Colors.white;
                        alinhamento = Alignment.centerLeft;
                      }

                      return Align(
                        alignment: alinhamento,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Container(
                            width: larguraContainer,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cor,
                              borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                            ),
                            child: Text(
                              item["mensagem"],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              break;
            default:
              return Center(
                child: Column(
                  children: const [
                    Text("Erro ao carregar as mensagens. Tente novamente.")
                  ],
                ),
              );
          }
        },
      );
    }



    var listView = Expanded(
      child: ListView.builder(
        itemCount: listaMensagens.length,
        itemBuilder: (context, indice) {
          double larguraContainer = MediaQuery.of(context).size.width * 0.75;
          // Define cores e alinhamentos
          Alignment alinhamento = Alignment.centerRight;
          Color cor = const Color(0xffD2FFA5);
          if (indice % 2 == 0) {
            cor = Colors.white;
            alinhamento = Alignment.centerLeft;
          }

          return Align(
            alignment: alinhamento,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Container(
                width: larguraContainer,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Text(
                  listaMensagens[indice],
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              maxRadius: 20,
              backgroundColor: Colors.grey,
              backgroundImage: widget.contato.urlImagem != null
                  ? NetworkImage(widget.contato.urlImagem)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(widget.contato.nome),
            ),
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [retornaStream(), caixaMensagem],
            ),
          ),
        ),
      ),
    );
  }
}
