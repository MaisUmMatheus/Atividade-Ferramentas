import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EquipamentosPage extends StatefulWidget {
  @override
  _EquipamentosPageState createState() => _EquipamentosPageState();
}

class _EquipamentosPageState extends State<EquipamentosPage> {
  List<dynamic> equipamentos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEquipamentos();
  }

  Future<void> fetchEquipamentos() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://app-web-uniara-example-60f73cc06c77.herokuapp.com/equipamentos'),
      );

      if (response.statusCode == 200) {
        setState(() {
          equipamentos = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar equipamentos');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  Future<void> reservarEquipamento(
      int equipamentoId, DateTime dataRetirada) async {
    final equipamento =
        equipamentos.firstWhere((e) => e['id'] == equipamentoId);

    if (!equipamento['disponivel']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Este equipamento já está reservado.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'https://app-web-uniara-example-60f73cc06c77.herokuapp.com/equipamentos/$equipamentoId/reservar'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'data_retirada':
              dataRetirada.toIso8601String(), // Enviar a data escolhida
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          equipamento['disponivel'] = false;
          equipamento['data_retirada'] =
              jsonResponse['data_retirada'] ?? dataRetirada.toIso8601String();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Equipamento reservado com sucesso!'),
        ));
      } else {
        final errorResponse = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Erro: ${errorResponse['error'] ?? 'Falha ao reservar equipamento'}'),
        ));
      }
    } catch (e) {
      print('Erro ao reservar: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao reservar equipamento'),
      ));
    }
  }

  Future<void> mostrarDialogoDataReserva(int equipamentoId) async {
    DateTime? dataEscolhida;

    // Exibe o DatePicker para o usuário selecionar a data
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != DateTime.now()) {
      dataEscolhida = picked;

      // Chama a função de reservar com a data escolhida
      await reservarEquipamento(equipamentoId, dataEscolhida);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Equipamentos')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: equipamentos.length,
              itemBuilder: (context, index) {
                final equipamento = equipamentos[index];
                return ListTile(
                  title: Text(equipamento['nome']),
                  subtitle: Text(equipamento['disponivel']
                      ? 'Disponível'
                      : 'Reservado até: ${equipamento['data_retirada'] != null ? DateTime.parse(equipamento['data_retirada']).toLocal().toString() : "Não disponível"}'),
                  trailing: equipamento['disponivel']
                      ? ElevatedButton(
                          onPressed: () {
                            mostrarDialogoDataReserva(equipamento['id']);
                          },
                          child: Text('Reservar'),
                        )
                      : null,
                );
              },
            ),
    );
  }
}
