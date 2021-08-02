class Conversa {

  late String _nome;
  late String _mensagem;
  late String _caminhoFoto;


  Conversa(this._nome, this._mensagem, this._caminhoFoto);

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
}