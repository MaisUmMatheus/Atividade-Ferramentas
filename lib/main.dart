import 'package:flutter/material.dart';
import 'cadastro_equipamento.dart';
import 'equipamentos.dart';
import 'tela_inicial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciamento de Equipamentos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TelaInicial(),
      routes: {
        '/equipamentos': (context) => EquipamentosPage(),
        '/cadastro': (context) => CadastroEquipamentoPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
