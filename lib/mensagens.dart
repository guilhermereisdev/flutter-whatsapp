import 'package:flutter/material.dart';

import 'model/usuario.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato, {Key? key}) : super(key: key);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  TextEditingController _controllerMensagem = TextEditingController();

  _enviarMensagem() {}

  _enviarFoto() {}

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
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
                      color: Color(0xff075E54),size: 20 ,
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.contato.nome)),
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
              children: [
                // listview
                Text("listview"),
                //caixa de mensagem
                caixaMensagem
              ],
            ),
          ),
        ),
      ),
    );
  }
}
