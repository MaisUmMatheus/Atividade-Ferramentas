import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroEquipamentoPage extends StatefulWidget {
  @override
  _CadastroEquipamentoPageState createState() =>
      _CadastroEquipamentoPageState();
}

class _CadastroEquipamentoPageState extends State<CadastroEquipamentoPage> {
  final _formKey = GlobalKey<FormState>();
  String nomeEquipamento = '';
  List<dynamic> equipamentos = [];

  Future<void> fetchEquipamentos() async {
    final response = await http.get(
      Uri.parse(
          'https://app-web-uniara-example-60f73cc06c77.herokuapp.com/equipamentos'),
    );
    if (response.statusCode == 200) {
      equipamentos = json.decode(response.body);
    }
  }

  Future<void> cadastrarEquipamento() async {
    await fetchEquipamentos(); // Puxar equipamentos para verificar duplicatas

    // Verifica se o equipamento já existe ou está reservado
    final equipamentoExistente = equipamentos.firstWhere(
      (e) => e['nome'] == nomeEquipamento,
      orElse: () => null,
    );

    if (equipamentoExistente != null) {
      if (equipamentoExistente['disponivel'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Este equipamento já está reservado.')),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Este equipamento já existe e está disponível.')),
        );
        return;
      }
    }

    // Se não existir, cadastra o equipamento
    final response = await http.post(
      Uri.parse(
          'https://app-web-uniara-example-60f73cc06c77.herokuapp.com/equipamentos'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'nome': nomeEquipamento, 'disponivel': true}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Equipamento cadastrado com sucesso!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Erro ao cadastrar equipamento. Código: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Equipamento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome do Equipamento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do equipamento';
                  }
                  return null;
                },
                onChanged: (value) {
                  nomeEquipamento = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    cadastrarEquipamento();
                  }
                },
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
