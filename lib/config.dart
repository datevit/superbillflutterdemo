class Config {
  static const clientId = '<YOUR_CLIENT_ID>';
  static const clientSecret = '<YOUR_CLIENT_SECRET>';

  static const String authorizationKey = '<YOUR_AUTHORIZATION_KEY>';
  static const String userTenant = '<YOUR_TENANT_ID>';

  // Questo indirizzo va aggiunto all'elenco degli "URI di reindirizzamento"
  // nella configurazione dell'applicazione di integrazione. Sono richieste
  // anche configurazioni specifiche per iOS e Android, come indicato qui:
  // https://pub.dev/packages/flutter_appauth
  static const String redirectUri = 'it.datev.superbilldemo://login-callback';
}
