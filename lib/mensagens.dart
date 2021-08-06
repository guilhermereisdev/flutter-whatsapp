import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp/model/conversa.dart';
import 'package:flutter_whatsapp/model/mensagem.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'model/usuario.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato, {Key? key}) : super(key: key);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  late File _imagem;
  bool _subindoImagem = false;
  late final imagemSelecionada;
  late String _idUsuarioLogado = " ";
  late String _idUsuarioDestinatario = " ";

  FirebaseFirestore db = FirebaseFirestore.instance;

  Usuario _usuarioLogado2 = Usuario();

  TextEditingController _controllerMensagem = TextEditingController();

  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.data = Timestamp.now().toString();
      mensagem.tipo = "texto";

      // salva a mensagem para o remetente
      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

      // salva a mensagem para o destinatário
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

      // salvar conversa
      _salvarConversa(mensagem);
    }
  }

  _salvarConversa(Mensagem msg) {
    // salvar conversa remetente
    Conversa cRemetente = Conversa();
    cRemetente.idRemetente = _idUsuarioLogado;
    cRemetente.idDestinatario = _idUsuarioDestinatario;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.urlImagem;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.data = msg.data;
    cRemetente.salvar();

    // salvar conversa destinatário
    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = _idUsuarioDestinatario;
    cDestinatario.idDestinatario = _idUsuarioLogado;
    cDestinatario.mensagem = msg.mensagem;
    //cDestinatario.nome = widget.contato.nome;
    //cDestinatario.caminhoFoto = widget.contato.urlImagem;
    cDestinatario.nome = _usuarioLogado2.nome;
    cDestinatario.caminhoFoto = _usuarioLogado2.urlImagem;

    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.data = msg.data;
    cDestinatario.salvar();
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

  _enviarFoto() async {
    ImagePicker _picker = ImagePicker();
    imagemSelecionada = await _picker.pickImage(source: ImageSource.gallery);
    _uploadImagem();
  }

  Future _uploadImagem() async {
    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;
    firebase_storage.Reference pastaRaiz = storage.ref();
    firebase_storage.Reference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idUsuarioLogado)
        .child(nomeImagem + ".jpg");

    // upload da imagem
    firebase_storage.UploadTask task =
        arquivo.putFile(File(imagemSelecionada.path));

    // controlar progresso do upload
    task.snapshotEvents.listen((firebase_storage.TaskSnapshot taskSnapshot) {
      if (taskSnapshot.state == firebase_storage.TaskState.running) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (taskSnapshot.state == firebase_storage.TaskState.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });

    // recuperar url da imagem
    task.then((firebase_storage.TaskSnapshot taskSnapshot) {
      _recuperarUrlImagem(taskSnapshot);
    });
  }

  Future _recuperarUrlImagem(firebase_storage.TaskSnapshot taskSnapshot) async {
    String url = await taskSnapshot.ref.getDownloadURL();
    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.data = Timestamp.now().toString();
    mensagem.tipo = "imagem";

    // salva a mensagem para o remetente
    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

    // salva a mensagem para o destinatário
    _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser as User;

    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc(usuarioLogado.uid).get();

    var user = snapshot.data();

    setState(() {
      _idUsuarioLogado = usuarioLogado.uid;
      _idUsuarioDestinatario = widget.contato.idUsuario;

      _usuarioLogado2.nome = (user as dynamic)["nome"];
      _usuarioLogado2.urlImagem = (user as dynamic)["urlImagem"];
      _usuarioLogado2.email = usuarioLogado.email!;
    });
    _adicionarListenerMensagens();
  }

  _adicionarListenerMensagens() {
    final stream = db
        .collection("mensagens")
        .doc(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario)
        .orderBy("data", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
      // rola a lista de mensagens para o final
      Timer(const Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
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
                  prefixIcon: _subindoImagem
                      ? const CircularProgressIndicator()
                      : IconButton(
                          onPressed: () {
                            _enviarFoto();
                          },
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Color(0xff075E54),
                            size: 22,
                          ),
                        ),
                ),
              ),
            ),
          ),
          if (Platform.isIOS)
            CupertinoButton(
              child: const Icon(Icons.send),
              onPressed: _enviarMensagem,
            )
          else
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

    var stream = StreamBuilder(
      // Listener que verifica se há alguma alteração nas mensagens
      stream: _controller.stream,
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
                  controller: _scrollController,
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
                          child: item["tipo"] == "texto"
                              ? Text(item["mensagem"],
                                  style: const TextStyle(fontSize: 16))
                              : Image.network(item["urlImagem"]),
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
              children: [stream, caixaMensagem],
            ),
          ),
        ),
      ),
    );
  }
}
