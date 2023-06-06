import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:superbilldemo/config.dart';
import 'package:superbilldemo/nav_menu.dart';

import 'main.dart';

class DittePage extends StatefulWidget {
  final Future<void> Function() logoutAction;

  const DittePage({required this.logoutAction, Key? key}) : super(key: key);

  @override
  State<DittePage> createState() => _DittePageState();
}

class _DittePageState extends State<DittePage> {
  bool isBusy = false;
  String? accessToken;

  @override
  void initState() {
    initAction();
    super.initState();
  }

  Future<void> initAction() async {
    setState(() {
      isBusy = true;
    });
    final token = await secureStorage.read(key: 'access_token');
    setState(() {
      accessToken = token;
      isBusy = false;
    });
  }

  final uri = Uri.parse('https://superbillapp.datev.it/efat/api/v1/ditte');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Elenco ditte",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
              ])),
        ),
      ),
      drawer: NavMenu(
        isLoggedIn: true,
        logoutAction: widget.logoutAction,
      ),
      body: Container(
        child: isBusy
            ? const CircularProgressIndicator()
            : FutureBuilder<http.Response>(
                future: http.get(uri, headers: <String, String>{
                  'Authorization': 'Bearer $accessToken',
                  'Authorization-Key': Config.authorizationKey,
                  'User-Tenant': Config.userTenant
                }),
                builder: (BuildContext context,
                    AsyncSnapshot<http.Response> snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Impossibile caricare l\'elenco ditte");
                  }
                  if (snapshot.hasData) {
                    final response = snapshot.data!;
                    if (response.statusCode == 200) {
                      Iterable l = json.decode(response.body);
                      List<Ditta> ditte = List<Ditta>.from(
                          l.map((model) => Ditta.fromJson(model)));

                      return ListView(
                        children: ditte.map((ditta) {
                          return ListTile(
                            title: Text(ditta.descrizione),
                            subtitle: Text(ditta.codice),
                          );
                        }).toList(),
                      );
                    } else {
                      return Text(
                          "Qualcosa è andato storto: ${response.reasonPhrase}");
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
      ),
    );
  }
}

class Ditta {
  final String codice;
  final String descrizione;

  Ditta(this.descrizione, this.codice);

  Ditta.fromJson(Map<String, dynamic> json)
      : descrizione = json['descrizione'],
        codice = "id: ${json['idElemento']} codice: ${json['codice']}";

  Map<String, dynamic> toJson() => {
        'Descrizione': descrizione,
        'Codice': codice,
      };
}