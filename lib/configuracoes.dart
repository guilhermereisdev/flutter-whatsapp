import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Configuracoes extends StatefulWidget {
  const Configuracoes({Key? key}) : super(key: key);

  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _controllerNome = TextEditingController();
  late File _imagem;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configurações")),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Carregando
                const CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(
                      "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-1.appspot.com/o/perfil%2Fperfil5.jpg?alt=media&token=70077d23-3d20-42ae-8656-2021d7fde3f8"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Text("Câmera"),
                      onPressed: () {
                        _recuperarImagem("camera");
                      },
                    ),
                    TextButton(
                      child: Text("Galeria"),
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    onPressed: () {},
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
