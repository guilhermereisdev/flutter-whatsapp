import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa {
  late String _idRemetente;
  late String _idDestinatario;
  late String _nome;
  late String _mensagem;
  late String _caminhoFoto;
  late String _tipoMensagem; // texto ou imagem
  late String _data;

  Conversa();

  salvar() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("conversas")
        .doc(this.idRemetente)
        .collection("ultima_conversa")
        .doc(this.idDestinatario)
        .set(this.toMap());
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idRemetente": this.idRemetente,
      "idDestinatario": this.idDestinatario,
      "nome": this.nome,
      "mensagem": this.mensagem,
      "caminhoFoto": this.caminhoFoto,
      "tipoMensagem": this.tipoMensagem,
      "data": this.data,
    };
    return map;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get idRemetente => _idRemetente;

  set idRemetente(String value) {
    _idRemetente = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get mensagem => _mensagem;

  String get caminhoFoto => _caminhoFoto;

  set caminhoFoto(String value) {
    _caminhoFoto = value;
  }

  set mensagem(String value) {
    _mensagem = value;
  }

  String get idDestinatario => _idDestinatario;

  set idDestinatario(String value) {
    _idDestinatario = value;
  }

  String get tipoMensagem => _tipoMensagem;

  set tipoMensagem(String value) {
    _tipoMensagem = value;
  }
}
