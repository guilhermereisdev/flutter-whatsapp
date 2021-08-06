import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class Configuracoes extends StatefulWidget {
  const Configuracoes({Key? key}) : super(key: key);

  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _controllerNome = TextEditingController();
  late File _imagem;
  late String _idUsuarioLogado;
  bool _subindoImagem = false;
  late String _urlImagemRecuperada = "";

  Future _recuperarImagem(String origemImagem) async {
    ImagePicker _picker = ImagePicker();
    final imagemSelecionada;
    switch (origemImagem) {
      case "camera":
        imagemSelecionada = await _picker.pickImage(source: ImageSource.camera);
        break;
      case "galeria":
        imagemSelecionada =
            await _picker.pickImage(source: ImageSource.gallery);
        break;
      default:
        imagemSelecionada =
            await _picker.pickImage(source: ImageSource.gallery);
        break;
    }
    setState(() {
      _imagem = File(imagemSelecionada.path);
      if (_imagem != null) {
        _subindoImagem = true;
        _uploadImagem();
      }
    });
  }

  Future _uploadImagem() async {
    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;
    firebase_storage.Reference pastaRaiz = storage.ref();
    firebase_storage.Reference arquivo =
        pastaRaiz.child("perfil").child(_idUsuarioLogado + "_foto_perfil.jpg");

    // upload da imagem
    firebase_storage.UploadTask task = arquivo.putFile(_imagem);

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
    _atualizarUrlImagemFirestore(url);
    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  _atualizarUrlImagemFirestore(String url) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> dadosAtualizar = {"urlImagem": url};

    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  _atualizarNomeFirestore() {
    String nome = _controllerNome.text;
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> dadosAtualizar = {"nome": nome};

    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
    Navigator.pop(context);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    User usuarioLogado = await auth.currentUser!;
    _idUsuarioLogado = usuarioLogado.uid;

    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc(_idUsuarioLogado).get();

    var dados = snapshot.data();
    _controllerNome.text = (dados as dynamic)["nome"];

    if (dados["urlImagem"] != null) {
      setState(() {
        _urlImagemRecuperada = (dados as dynamic)["urlImagem"];
      });
    }
  }

  @override
  void initState() {
    _recuperarDadosUsuario();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configurações")),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: _subindoImagem
                      ? const CircularProgressIndicator()
                      : Container(),
                ),
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage: _urlImagemRecuperada != null
                      ? NetworkImage(_urlImagemRecuperada)
                      : null,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: const Text("Câmera"),
                      onPressed: () {
                        _recuperarImagem("camera");
                      },
                    ),
                    TextButton(
                      child: const Text("Galeria"),
                      onPressed: () {
                        _recuperarImagem("galeria");
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Nome",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                    /*onChanged: (texto) {
                      _atualizarNomeFirestore(texto);
                    },*/
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    onPressed: () {
                      _atualizarNomeFirestore();
                    },
                    child: const Text("Salvar",
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    color: Colors.green,
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
