import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:superbilldemo/config.dart';
import 'package:superbilldemo/nav_menu.dart';
import 'package:superbilldemo/profile.dart';

import 'login.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

const _redirectUri = Config.redirectUri;
const _authority = 'login.datev.it';
const _authUrl = 'https://$_authority';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Superbill Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title = 'Superbill Demo';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage = '';
  String name = '';
  String picture = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Superbill Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Superbill Demo'),
        ),
        drawer: NavMenu(
          isLoggedIn: isLoggedIn,
          logoutAction: logoutAction,
        ),
        body: Center(
          child: isBusy
              ? const CircularProgressIndicator()
              : isLoggedIn
                  ? Profile(logoutAction, name, picture)
                  : Login(loginAction, errorMessage),
        ),
      ),
    );
  }

  Map<String, dynamic> parseIdToken(String idToken) {
    final List<String> parts = idToken.split('.');
    assert(parts.length == 3);

    final token = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));

    final result = jsonDecode(token);

    return result;
  }

  Future<Map<String, dynamic>> getUserDetails(String accessToken) async {
    const String url = 'https://$_authority/connect/userinfo';
    final http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  Future<void> loginAction() async {
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
      final AuthorizationTokenResponse? result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          Config.clientId,
          _redirectUri,
          clientSecret: Config.clientSecret,
          issuer: _authUrl,
          scopes: <String>[
            'openid',
            'profile',
            'config',
            'efat',
            'offline_access'
          ],
          // promptValues: ['login']
        ),
      );

      if (result != null) {
        final Map<String, dynamic> profile =
            await getUserDetails(result.accessToken!);

        await secureStorage.write(
            key: 'refresh_token', value: result.refreshToken);

        await secureStorage.write(
            key: 'access_token', value: result.accessToken);

        setState(() {
          isBusy = false;
          isLoggedIn = true;
          name = profile['name'];
          picture = profile['picture'] ??
              'https://www.gravatar.com/avatar/ddb248d7a11d4fffe2cfbf0d96987414?s=150';
        });
      }
    } on Exception catch (e, s) {
      debugPrint('login error: $e - stack: $s');

      setState(() {
        isBusy = false;
        isLoggedIn = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> logoutAction() async {
    await secureStorage.delete(key: 'refresh_token');
    setState(() {
      isLoggedIn = false;
      isBusy = false;
    });
  }

  @override
  void initState() {
    initAction();
    super.initState();
  }

  Future<void> initAction() async {
    final String? storedRefreshToken =
        await secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken == null) return;

    setState(() {
      isBusy = true;
    });

    try {
      final TokenResponse? response = await appAuth.token(TokenRequest(
        Config.clientId,
        _redirectUri,
        clientSecret: Config.clientSecret,
        issuer: _authUrl,
        refreshToken: storedRefreshToken,
      ));

      if (response != null) {
        final Map<String, dynamic> profile =
            await getUserDetails(response.accessToken!);

        await secureStorage.write(
            key: 'refresh_token', value: response.refreshToken);

        setState(() {
          isBusy = false;
          isLoggedIn = true;
          name = profile['name'];
          picture = profile['picture'];
        });
      }
    } on Exception catch (e, s) {
      debugPrint('error on refresh token: $e - stack: $s');
      await logoutAction();
    }
  }
}
