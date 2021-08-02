import 'package:flutter/material.dart';
import 'package:flutter_whatsapp/model/conversa.dart';

class AbaContatos extends StatefulWidget {
  const AbaContatos({Key? key}) : super(key: key);

  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  List<Conversa> listaConversas = [
    Conversa("Ana Clara", "Olá!",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-1.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=bca891fa-1f01-4e48-a9f5-be270fd59173"),
    Conversa("Jorge Vercilo", "Opa! Monalisa...",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-1.appspot.com/o/perfil%2Fperfil2.jpg?alt=media&token=fe30e6a8-1b6b-48b6-aa00-b51de46074c9"),
    Conversa("Marcela Almeida", "Bora tomar uma?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-1.appspot.com/o/perfil%2Fperfil3.jpg?alt=media&token=8d4977d4-aa97-4713-801d-a076c8aeadd2"),
    Conversa("José Renato", "Me empreste um real?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-1.appspot.com/o/perfil%2Fperfil4.jpg?alt=media&token=98897de4-bcba-4aa2-8559-a1fe5fca2c5a"),
    Conversa("Jamilton Damasceno", "Vc é meu melhor aluno!",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-1.appspot.com/o/perfil%2Fperfil5.jpg?alt=media&token=70077d23-3d20-42ae-8656-2021d7fde3f8"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listaConversas.length,
      itemBuilder: (context, indice) {
        Conversa conversa = listaConversas[indice];
        return ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          leading: CircleAvatar(
            maxRadius: 30,
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(conversa.caminhoFoto),
          ),
          title: Text(
            conversa.nome,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      },
    );
  }
}
