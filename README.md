# Inizia a sviluppare con SuperBill

  

[SuperBill](https://www.superbill.it/) è un software di gestione della fatturazione per le piccole e medie imprese prodotto da [Datev Koinos](https://www.datevkoinos.it/). SuperBill offre un interfaccia API per integrare software di terze parti e un sistema di autenticazione e autorizzazione nello standard OpenID Connect.

  

## SupebillFlutterDemo

  

SuperbillFlutterDemo é una applicazione di esempio multipiattaforma scritta in Flutter, che ti permette di prendere confidenza con le API di SuperBill. Per semplicità SuperbillFlutterDemo non utilizza un database per memorizzare alcune informazioni necessarie, sia per individure il tenant dell'utente che per il salvataggio l'Authorization-Key utilizzata dalle API per il controllo della licenza. Queste informazioni che vanno configurate staticamente nel file [config.dart](https://github.com/datevit/superbillflutterdemo/blob/main/lib/config.dart), così come gli identificativi di autenticazione *client_id* e *client_secret* della tua applicazione. Fare riferimento alla guida sul sito [Developers Datev Koinos](https://developer.datev.it/) per registrare e configurare una nuova applicazione.

  
  

### Prerequisiti

Per utilizzare SuperbillFlutterDemo é necessario aver installato l'SDK di Flutter (testato con la versione 3.10) e aver registrato e configurato una applicazione di integrazione sul sito sviluppatori Datev Koinos (maggiori informazioni [qui](https://developer.datev.it/)).

Nella configurazione della applicazione di integrazione riportare negli URI di reindirizzamento l'indirizzo it.datev.superbilldemo://login-callback (it.datev.superbilldemo è lo schema di default definito per l'applicazione di esempio) nell'elenco degli **URI di reindirizzamento** e selezionare le autorizzazioni **profile**, **openid**, **config**, **integrasdi** e **efat**.

  

### Setup del progetto

  

1. Esegui il clone di questo repository

```bash

git clone https://github.com/datevit/superbillflutterdemo.git

```

  

2. Installa le dipendenze del progetto

```bash

cd  superbillflutterdemo
flutter pub get

```

  

3. Sostituisci nel file .\lib\config.dart <YOUR_CLIENT_ID> e <YOUR_CLIENT_SECRET> con il *Client ID* e il *Client secret* della tua applicazione di integrazione, sostituisci inoltre <YOUR_AUTHORIZATION_KEY> con l'Authorization-Key della licenza di Superbill e <YOUR_TENANT_ID> con l'identificativo dello **User-Tenant** collegato all'account utilizzato per eseguire la login. L'identificativo *User-Tenant* può essere ottenuto tramite API, per semplicità in questa applicazione di esempio è stato utilizzato un valore *hardcoded*.
Per recuperare lo *User-Tenant* collegato all'account utilizzato, puoi seguire questi passaggi:
- collegati al sito https://superbill.datev.it/ ed effettua la login
- lancia l'applicazione Fatture, il tuo **User-Tenant** corrisponde al valore del parametro tenant_id dell'URL dell'applicazione https://superbillapp.datev.it/efat/default.aspx?tenant_id=<YOUR_TENANT_ID>.

4. Esegui l'applicazione

```bash

flutter  devices  # per ottenere l'elenco dei dispositivi disponibili
flutter  devices  -d <device-id> # identificativo del device che si intende utilizzare

```