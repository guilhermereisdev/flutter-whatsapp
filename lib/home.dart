import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_whatsapp/telas/aba_contato.dart';
import 'package:flutter_whatsapp/telas/aba_conversas.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WhatsApp"),
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Conversas"),
            Tab(text: "Contatos"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AbaConversas(),
          AbaContatos(),
        ],
      ),
    );
  }
}
