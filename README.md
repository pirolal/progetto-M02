# Progetto Magazzino di smistamento

![immagine magazzino](https://github.com/user-attachments/assets/30e5e9d6-5495-4f3c-a050-a59da9d4cb9d)

- Progetto svolto da
  - Pirola Luca
  - Epis Tommaso
  - Neagu Andrei Angelo

## problema 1: Monitoraggio Baie di Scarico (Indact)
### Script: ./sensore_baita_multiplo.sh
#### Soluzione proposta e funzionamento:
Il sistema monitora costantemente le 3 baie di scarico tramite sensori e telecamere. Lo script Bash agisce in ascolto leggendo l'input da un modulo Python che genera dati casuali su targhe, orari e numero di pacchi. Permette di visualizzare lo stato live delle baie o di consultare lo storico per identificare i volumi di carico e i TIR arrivati.


#### Manuale Operativo:
- Monitoraggio LIVE: ./sensore_baita_multiplo.sh (mostra lo stato attuale delle baie B1, B2, B3).
  ```
  [16:42] [B1:vuoto] [B2:vuoto] [B3:vuoto] | Magazzino: 0 pacchi
  [16:43] [B1:vuoto] [B2:vuoto] [B3:vuoto] | Magazzino: 0 pacchi

  ```
- Storico Giornaliero: ./sensore_baita_multiplo.sh -d [data] (es: 2026-02-22).
  ```
  -------------------------------------------------------
  DATA | TARGA | PACCHI | ORA
  -------------------------------------------------------
  2026-02-22 | EF749JA | 419 | 11:52
  2026-02-22 | CQ712WX | 336 | 11:52
  2026-02-22 | PQ230SN | 407 | 11:54
  2026-02-22 | QC537DG | 142 | 04:04
  2026-02-22 | UX994XF | 118 | 21:23
  2026-02-22 | SV648AY | 76 | 13:56
  -------------------------------------------------------
  RIASSUNTO:
  Numero totale TIR: 6
  Totale pacchi scaricati: 1498

  ```
- Comparazione Periodo: ./sensore_baita_multiplo.sh -g [data_inizio] [data_fine].
  ```
  -------------------------------------------------------
  DATA | TARGA | PACCHI | ORA
  -------------------------------------------------------
  2026-02-02 | YN913LY | 403 | 16:40
  2026-02-02 | UM238KG | 295 | 00:36
  2026-02-02 | EW136YL | 258 | 00:36
  2026-02-02 | XO257VL | 131 | 00:36
  2026-02-02 | PK900SQ | 129 | 00:31
  2026-02-02 | DP241NO | 147 | 19:43
  2026-02-02 | AW458KC | 97 | 22:52
  2026-02-03 | KF730NY | 296 | 04:14
  -------------------------------------------------------
  RIASSUNTO:
  numero totale TIR: 8
  Totale pacchi scaricati: 1756
  
  ```
- Ricerca Record: ./sensore_baita_multiplo.sh -M [data] (mostra il TIR più carico del giorno).
  ```
  Data: 2026-02-02
  -------------------------------------------------------
  IL TIR PIÙ CARICO TROVATO:
  Targa: YN913LY
  Pacchi: 403
  Data: 2026-02-02 ore 16:40

  ```


## problema 2: Monitoraggio produttività dei dipendenti
### Script: ./filtra.sh
#### Soluzione proposta e funzionamento:
Lo script monitora lo stoccaggio dei pacchi per ogni dipendente. Permette di verificare il rendimento giornaliero, analizzare la "carriera" lavorativa di una specifica matricola o individuare chi ha stabilito il record di pacchi stoccati (sparati) in un determinato arco temporale.


#### Manuale Operativo:
- Situazione Odierna: ./filtra.sh (mostra il totale pacchi e il dettaglio per matricola di oggi).
  ```
  TOTALE PACCHI OGGI: 562
  -----------------------------------
  Dettaglio per matricola:
  - Matricola 01: 329 pacchi
  - Matricola 02: 233 pacchi

  ```
- Carriera Dipendente: ./filtra.sh -m [matricola] (es: 02).
  ```
  --- Carriera Matricola 02 ---
  2026-02-13: 371 pacchi
  2026-02-14: 213 pacchi
  2026-02-15: 155 pacchi
  2026-02-16: 160 pacchi
  2026-02-17: 195 pacchi
  2026-02-18: 317 pacchi
  2026-02-19: 396 pacchi
  2026-02-20: 351 pacchi
  2026-02-21: 490 pacchi
  2026-02-22: 233 pacchi
  TOTALONE CARRIERA: 2881

  ```
- Report Data Specifica: ./filtra.sh -d [data] (es: 2026-02-22).
  ```
  --- Report del 2026-02-22 ---
  Matricola 01: 329 pacchi
  Matricola 02: 233 pacchi

  ```
- Report Periodo: ./filtra.sh -g [data1] [data2].
  ```
   --- Report Totale Periodo (2026-02-16 / 2026-02-20) ---
  Totale pacchi nel periodo: 6521
  -----------------------------------
  Dettaglio per matricola:
  - Matricola 01: 1530 pacchi
  - Matricola 02: 1419 pacchi
  - Matricola 03: 1054 pacchi
  - Matricola 04: 1201 pacchi
  - Matricola 05: 1317 pacchi

  ```
- Ricerca Record: ./filtra.sh -M (può essere unito a -d o -g per trovare il recordman di quel periodo)  (es: 2026-02-22).
  ```
  --- Record nel giorno: ---
  Record di pacchi sparati: 2887 🏆
  Raggiunto da:
  - Matricola: 01

  ```


## problema 3: Fondo rullo
### Script: ./rinvsens.sh
#### Soluzione proposta e funzionamento:
Monitora la parte finale del sistema di smistamento automatico. Un sensore rileva ogni 2 secondi l'altezza dei pacchi nel carrello; al raggiungimento della soglia critica di 100 cm, invia automaticamente un messaggio al device di un operatore per lo svuotamento, garantendo la continuità del flusso.


#### Manuale Operativo:
- Monitoraggio LIVE: ./rinvsens.sh (mostra l'altezza in tempo reale e attiva gli alert).
  ```
  [18:15:44] 13.85 cm
  [18:15:47] 16.61 cm
  ...
  [18:16:21] 100.52 cm
  ------------------------------------------------
  ⚠️ Soglia superata! Svuotare carrello.
  ------------------------------------------------

  ```
- Analisi Giorno Singolo: ./rinvsens.sh -d [data] (conta quante volte la soglia è stata superata).
  ```
  Analisi: 2026-02-01 / 2026-02-01
  ------------------------------------------------
  2026-02-01 [08:00] - 116.81 cm
  2026-02-01 [08:40] - 106.51 cm
  2026-02-01 [11:20] - 122.64 cm
  2026-02-01 [15:40] - 101.75 cm
  2026-02-01 [17:20] - 109.28 cm
  2026-02-01 [18:00] - 108.21 cm
  2026-02-01 [18:20] - 104.15 cm
  2026-02-01 [19:00] - 101.0 cm
  2026-02-01 [20:00] - 128.98 cm
  2026-02-01 [21:40] - 113.06 cm
  2026-02-01 [22:40] - 105.64 cm
  2026-02-01 [23:40] - 104.68 cm
  ------------------------------------------------
  Totale superamenti soglia: 12


  ```
- Analisi Intervallo: ./rinvsens.sh -g [inizio] [fine]  (mostra tutte le volte che la soglia ha superato i 100cm, nelrange tra le due date).
  ```
  Analisi: 2026-02-02 / 2026-02-03
  ------------------------------------------------
  2026-02-02 [10:20] - 129.25 cm
  2026-02-03 [23:00] - 126.6 cm
  2026-02-03 [23:20] - 115.11 cm
  ------------------------------------------------

  ```



## problema 4: Gestione Assenze e sostituzioni dei corrieri
### Script: ./contatta_corrieri.sh
#### Soluzione proposta e funzionamento:
Il sistema automatizza il protocollo di emergenza. Esegue un appello digitale istantaneo, rileva le mancanze e attinge immediatamente a un database di riserva. Attraverso una simulazione di contatto intelligente, il software assegna i sostituti in tempo reale, garantendo che ogni mattina l'organico sia sempre di 20 operatori su 20, annullando i tempi morti di coordinamento.


#### Manuale Operativo:
File principale: contatta_corrieri.sh

- Comando: ./contatta_corrieri.sh
  ```
  STAZIONE: Marco Rossi    STATUS: [PRESENTE]
  STAZIONE: Luca Bianchi   STATUS: [ASSENTE]
  STAZIONE: Sara Verdi     STATUS: [PRESENTE]
  STAZIONE: Elena Viola    STATUS: [ASSENTE]
  STAZIONE: Mario Rossi    STATUS: [PRESENTE]
  STAZIONE: Giulia Esposito        STATUS: [PRESENTE]
  STAZIONE: Matteo Ricci   STATUS: [PRESENTE]
  STAZIONE: Chiara Marino          STATUS: [PRESENTE]
  STAZIONE: Davide Greco   STATUS: [PRESENTE]
  ...
  STAZIONE: Valentina Bruno        STATUS: [ASSENTE]
  STAZIONE: Simone Gallo   STATUS: [PRESENTE]

  ------------------------------------------------
  >>> RILEVATE ASSENZE NEI 20 SLOT. AVVIO RICERCA...
  
  SOSTITUZIONE PER: Valentina Bruno
  Chiamata a Rossella Ferraro (3339900778)... ACCETTATO
  
  SOSTITUZIONE PER: Luca Bianchi
  Chiamata a Nicole Piras (3472233444)... ACCETTATO
  
  SOSTITUZIONE PER: Elena Viola
  Chiamata a Daniele Pellegrini (3495566227)... RIFIUTATO
  Chiamata a Aurora Rinaldi (3201122117)... ACCETTATO

  ```
- Logica: Lo script avvia il modulo Python generatore_assenti.py per l'appello. Se vengono rilevati assenti, lo script Bash avvia una scansione ricorsiva sul database corrieri.csv finché non trova e conferma i sostituti necessari.
- Output: Genera un report ufficiale denominato registro_assenti.txt per le finalità amministrative.




## problema 5:  Tracciabilità Totale Smistamento
### Script: ./Simulatore.sh
#### Soluzione proposta e funzionamento:
Il Simulatore Smistamento Smart elimina l'incertezza. Ogni pacco che entra nel sistema viene registrato in un database SQLite e indirizzato digitalmente a un sensore specifico.
Questo crea un legame indissolubile tra il pacco, il cliente e la sua posizione fisica nel magazzino. 
In ogni istante, l'operatore può interrogare il sistema per sapere esattamente quale sensore ha processato un collo, azzerando gli smarrimenti interni.


#### Manuale Operativo:
File principali: Simulatore.sh (interfaccia CLI) e gestione_spedizioni.db (database).

- Inizializzazione: ./Simulatore.sh -i (Popola il database e avvia il flusso di smistamento automatico).
  ```
  --- Avvio Sequenza Smistamento ---
  Il pacco con ID 1 (Cliente: Luca) deve andare tramite il sensore 1
  Sensore 1 in movimento...
  Pacco arrivato nella tela 1
 
  Il pacco con ID 4 (Cliente: Luca) deve andare tramite il sensore 2
  Sensore 2 in movimento...
  Pacco arrivato nella tela 2
  -----------------------------------
  Il pacco con ID 5 (Cliente: Luca) deve andare tramite il sensore 3
  Sensore 3 in movimento...
  Pacco arrivato nella tela 3

  ```
- Filtro per Area: ./Simulatore.sh -s1 (oppure -s2, -s3) per visualizzare l'elenco dei pacchi presenti in una specifica zona di carico.
  ```
  Pacchi passati per il sensore 1:
  Pacco ID 1
  Pacco ID 3
  Pacco ID 6
  Pacco ID 13
  Pacco ID 16
  Pacco ID 20
  Pacco ID 21
  Pacco ID 22
  Pacco ID 23
  Pacco ID 24

  ```
- Ricerca Puntuale: ./Simulatore.sh -p [ID] per ottenere il percorso esatto e il sensore di passaggio di un determinato pacco (es. ID=12).
  ```
  Il pacco 12 è passato dal sensore 3

  ```



## problema 6: Monitoraggio e Archiviazione Certificata
### Script: ./Accensione_Server.sh
#### Soluzione proposta e funzionamento:
Il monitoraggio è stato trasformato in un sistema di auditing automatico. Grazie a un server Node.js, ogni volta che viene aperta la dashboard web per visualizzare le telecamere, il sistema scatta automaticamente uno screenshot di tutti i sensori. Queste immagini vengono archiviate in un database fisico organizzato per Anno, Mese, Giorno e Ora, creando uno  storico inalterabile che documenta lo stato del magazzino a ogni singolo accesso.


#### Manuale Operativo:
File principali: Accensione_Server.sh e server.js.

- Avvio: Eseguire ./Accensione_Server.sh per attivare il server sulla porta 9000.
  ```
  Server in avvio su porta 9000
  Per chiudere il server, premi CTRL+C nel terminale.
  ------------------------------------------------
  SERVER ATTIVO: http://localhost:9000
  In attesa di connessione sulla pagina web...

  ```
- Utilizzo: Accedere tramite browser all'indirizzo http://localhost:9000.
- Automazione: All'apertura della pagina index.html, il sistema invia i segnali al server che provvede a creare la struttura delle cartelle, salvare i file JPG e aggiornare il registro cronologico report_accesso.csv.



## problema 7: Smarrimento pacchi durante il trasporto
### Script: ./problema10.sh
#### Soluzione proposta e funzionamento:
La soluzione prevede l’implementazione di un database centralizzato in cui vengono registrati tutti i pacchi che devono arrivare al magazzino, trasformando il sistema da reattivo a proattivo. Il sistema funziona in questo modo:
1.	Ogni pacco ritirato viene inserito nel database con: ID univoco, email del mittente, email del cliente, descrizione del contenuto e stato (atteso / arrivato).
2.	Uno script automatico confronta periodicamente l’elenco dei pacchi attesi con quelli effettivamente registrati all’arrivo.
3.	Se viene rilevata un’anomalia (pacco non arrivato nei tempi previsti):
    - Viene inviata automaticamente un’email al trasportatore per sollecitare il tracciamento.
    - Viene informato il cliente con una comunicazione di cortesia, anticipando il suo possibile reclamo.
Inoltre, il sistema permette di filtrare i pacchi, monitorare lo stato in tempo reale e garantire una tracciabilità totale che previene le "zone d'ombra" nel trasporto.


#### Manuale Operativo:
Questo modulo automatizza il tracciamento dei pacchi e le comunicazioni ai clienti.
1.	Abilitazione: Rendere eseguibile il file tramite chmod u+x problema4.sh.
2.	Sintassi e Parametri:
    - ./problema10.sh → Elenco generale della merce con stato di giacenza (In magazzino / In transito).
        ```
        ID    STATO      EMAIL AZIENDA                  EMAIL CLIENTE                 
        ---------------------------------------------------------------------------------------
        1     DENTRO     info@azienda1.it               giulia.marino1@example.com    
        2     FUORI      info@azienda2.it               emma.greco2@example.com        
        5     DENTRO     info@azienda5.it               sofia.rossi5@example.com      
        45    DENTRO     info@azienda45.it              emma.bianchi45@example.com    
        46    FUORI      info@azienda46.it              sofia.colombo46@example.com   
        47    FUORI      info@azienda47.it              luca.greco47@example.com      
        48    DENTRO     info@azienda48.it              luca.romano48@example.com    
      
        ```
    - ./problema10.sh -t → Mostra solo i pacchi già pervenuti correttamente (Stato: DENTRO).
        ```
        ID    STATO      EMAIL AZIENDA                  EMAIL CLIENTE                 
        ---------------------------------------------------------------------------------------
        1     DENTRO     info@azienda1.it               giulia.marino1@example.com    
        5     DENTRO     info@azienda5.it               sofia.rossi5@example.com      
        45    DENTRO     info@azienda45.it              emma.bianchi45@example.com    
        48    DENTRO     info@azienda48.it              luca.romano48@example.com      
      
        ```
    - ./problema10.sh -f → Mostra solo le mancanze e i pacchi ancora non arrivati (Stato: FUORI).
        ```
        ID    STATO      EMAIL AZIENDA                  EMAIL CLIENTE                 
        ---------------------------------------------------------------------------------------
        2     FUORI      info@azienda2.it               emma.greco2@example.com       
        46    FUORI      info@azienda46.it              sofia.colombo46@example.com   
        47    FUORI      info@azienda47.it              luca.greco47@example.com
      
        ```
    - ./problema10.sh -i → Report descrittivo dettagliato del contenuto di ogni pacco tramite ID.
        ```
        1     DENTRO          Smartphone modello 873                  
        2     FUORI           Monitor modello 348                                          
        5     DENTRO          Smartphone modello 348                                         
        45    DENTRO          Lampada modello 592                     
        46    FUORI           Cuffie modello 909                      
        47    FUORI           Smartphone modello 457                  
        48    DENTRO          Zaino modello 448                       
        49    DENTRO          Cuffie modello 468                      
        50    DENTRO          Tastiera modello 391
      
        ```
        
    - ./problema10.sh -e → Automazione Notifiche: attiva l'invio massivo di email. Invia solleciti ai fornitori e avvisi di ritardo ai clienti finali.
        ```
        ==========================================================
        SISTEMA AUTOMATIZZATO DI NOTIFICA LOGISTICA
        ==========================================================
        DA: magazzino@logistica.it
        A: info@azienda2.it
        OGGETTO: Avviso Mancata Ricezione Pacco #2
        
        Gentile Azienda,
        Vi informiamo che il pacco in oggetto (Monitor modello 348) NON è ancora
        pervenuto presso il nostro centro di smistamento.
        Vi preghiamo di verificare lo stato della spedizione.
        ----------------------------------------------------------
        DA: customer-service@logistica.it
        A: emma.greco2@example.com
        OGGETTO: Aggiornamento sulla tua consegna #2
        
        Caro Cliente,
        siamo spiacenti di informarti che la consegna del tuo ordine
        (Monitor modello 348) subirà un ritardo di circa 2/3 giorni lavorativi
        causa rallentamenti logistici.
        ----------------------------------------------------------
      
        ```
        
4.	User Experience: L'interfaccia terminale include barre di avanzamento grafiche che simulano il caricamento e l’invio dell’email  



## problema 8: Sovraccarico delle tele di smistamento
### Script: ./problema1.sh ./problema1.2.sh 
#### Soluzione proposta e funzionamento:
La soluzione prevede l’installazione di un sensore di peso su ciascuna delle tre tele, creando un sistema di sicurezza intelligente (fail-safe). Il sistema utilizza due soglie operative:

  - 300 kg → Soglia di attenzione: attivazione di un LED di avviso. Il dipendente viene avvisato visivamente e può iniziare lo svuotamento senza che la linea si fermi.
  - 500 kg → Soglia critica: isolamento automatico della tela dal rullo centrale. Il flusso si interrompe temporaneamente per salvaguardare l'integrità del macchinario e la sicurezza del personale.
L'intero processo viene monitorato da due script che registrano in tre file di log separati ogni evento (peso, stato LED, isolamento). Questo garantisce non solo prevenzione immediata, ma anche una memoria storica per la manutenzione.


#### Manuale Operativo:
Questo modulo gestisce l'acquisizione in tempo reale dei dati provenienti dai sensori dei rulli.
1.	Abilitazione: Per prima cosa, rendiamo eseguibili i due script tramite il comando chmod u+x problema1.sh problema1.2.sh.
2.	Esecuzione: Avviamo il sistema tramite ./problema1.sh. Questo comando agisce da orchestratore, lanciando in background 3 istanze parallele del modulo problema1.2.sh.
  ```
Avviato monitoraggio rullo 1
Avviato monitoraggio rullo 2
Avviato monitoraggio rullo 3
^C
⛔ Arresto monitoraggio...
✅ Tutti i rulli fermati


  ```
3.	Logica Operativa: Ogni istanza interroga un algoritmo stocastico Python (generatore.py) per simulare il carico sui rulli. Il sistema è programmato per essere operativo esclusivamente nella fascia oraria 08:00 - 22:00.
4.	Output: Vengono generati log cronologici nella cartella log_peso/, categorizzati per data e numero di tela (es: log_2026-02-22_tela1.log).
5.	Terminazione: Per arrestare il monitoraggio e chiudere in sicurezza tutti i processi attivi, utilizzare la combinazione di tasti CTRL+C.




## problema 9: Analisi dell’andamento delle tele e produttività
### Script: ./problema2.sh
#### Soluzione proposta e funzionamento:
Abbiamo sviluppato uno script di analisi generalizzato che elabora i dati dei file di log, trasformando i dati tecnici in indicatori strategici. Il sistema permette di:
  - Verificare la frequenza degli isolamenti delle tele e la durata delle interruzioni.
  - Analizzare il carico di lavoro in specifici intervalli orari per ottimizzare i turni del personale.
  - Effettuare confronti mensili o annuali, calcolando la variazione percentuale del volume gestito.
  - Identificare i "colli di bottiglia" strutturali su cui intervenire con nuovi investimenti.
Lo script restituisce statistiche pronte all'uso, permettendo una gestione aziendale basata sulla Business Intelligence.


#### Manuale Operativo:
Questo modulo processa i log generati dal Modulo 1 per estrarre statistiche di fermo macchina.
1.	Abilitazione: Rendere eseguibile lo script tramite chmod u+x problema2.sh.
2.	Sintassi e Parametri: L'analisi si adatta dinamicamente agli argomenti inseriti:
     - ./problema2.sh → Analisi rapida dei blocchi avvenuti nella data odierna.
       ```
          Le tele sono state ferme per 12 volte il 2026-02-09 tra 00:00 e 23:59
          Dettaglio fermate:
          10:33:36 - tela bloccata
          10:33:38 - tela bloccata
          10:33:39 - tela bloccata
          10:33:40 - tela bloccata
          10:33:43 - tela bloccata
          10:33:46 - tela bloccata
          10:33:47 - tela bloccata
          10:33:48 - tela bloccata
          10:33:49 - tela bloccata
          10:33:50 - tela bloccata
          10:33:54 - tela bloccata
          10:33:55 - tela bloccata
          
       ```
     - ./problema2.sh [RULLO]→ Focus specifico sulle performance di una singola linea di produzione.
       ```
          Il rullo 2 è stato fermo per 18 volte il 2026-02-22 tra 00:00 e 23:59
          Dettaglio fermate:
          10:32:47 - tela bloccata
          10:33:24 - tela bloccata
          10:33:25 - tela bloccata
          10:33:28 - tela bloccata
          10:33:29 - tela bloccata
          10:33:30 - tela bloccata
          10:33:31 - tela bloccata
          10:33:33 - tela bloccata
          10:33:34 - tela bloccata
          10:33:35 - tela bloccata
          10:33:36 - tela bloccata
          10:33:37 - tela bloccata
          10:33:41 - tela bloccata
          10:33:42 - tela bloccata
          10:33:43 - tela bloccata
          10:33:44 - tela bloccata
          10:33:45 - tela bloccata
                    
          
       ```
     - ./problema2.sh [YYYY-MM-DD]→ Report giornaliero con calcolo dei secondi totali di fermo e dettaglio orario.
        ```
          Le tele sono state ferme per 12 volte il 2026-02-09 tra 00:00 e 23:59
          Dettaglio fermate:
          15:08:43 - tela bloccata
          15:08:44 - tela bloccata
          15:08:49 - tela bloccata
          15:08:50 - tela bloccata
          15:08:51 - tela bloccata
          15:08:54 - tela bloccata
          15:08:43 - tela bloccata
          15:08:44 - tela bloccata
          15:08:45 - tela bloccata
          15:09:05 - tela bloccata
          15:09:06 - tela bloccata
          15:09:07 - tela bloccata
          
        ```
     - ./problema2.sh [DATA] [ORARIO] [RULLO] → Analisi granulare filtrata per data, fascia oraria e macchinario.
       ```
          Il rullo 3 è stato fermo per 6 volte il 2026-02-09 tra 15:08 e 15:09
          Dettaglio fermate:
          15:08:43 - tela bloccata
          15:08:44 - tela bloccata
          15:08:45 - tela bloccata
          15:09:05 - tela bloccata
          15:09:06 - tela bloccata
          15:09:07 - tela bloccata
          
       ```
     - ./problema2.sh -c [DATA1] [DATA2] → Business Intelligence: confronta le due date e calcola la variazione percentuale di efficienza lavorativa.
       ```
         Il giorno 2026-02-03 l'azienda ha lavorato il 20% in meno rispetto al 2026-02-09 (Blocchi: 2026-02-03=15, 2026-02-09=12)
       
       ```
4.	Output: I dati vengono processati e proiettati a terminale in formato testuale leggibile.



## problema 10: Controllo delle timbrature dei dipendenti
### Script: ./problema3.sh
#### Soluzione proposta e funzionamento:
La soluzione consiste nello sviluppo di uno script di gestione delle timbrature collegato a un database delle presenze sicuro e trasparente. Il sistema consente di:
1.	Automatizzare la registrazione: orario di entrata, uscita e calcolo immediato dei ritardi.
2.	Supportare la contabilità: i commercialisti possono visualizzare lo storico e calcolare le ore lavorate tramite un comando dedicato, riducendo a zero l'errore umano.
3.	Fornire strumenti decisionali: il datore di lavoro può verificare chi ha lavorato in una certa data, monitorare la frequenza dei ritardi e prendere decisioni contrattuali basate su dati oggettivi.
Il sistema garantisce precisione e trasparenza, migliorando il clima aziendale e l'efficienza burocratica.


#### Manuale Operativo:
Questo modulo gestisce l'anagrafica dinamica degli ingressi e delle uscite del personale.
1.	Abilitazione: Configurare i permessi tramite chmod u+x problema3.sh.
2.	Sintassi e Parametri:
    - ./problema3.sh → Visualizza istantaneamente il personale attualmente in servizio (Stato: IN).
       ```
         Dipendenti attualmente in servizio oggi (2026-02-22):
        -------------------------------------------
        Nessun dipendente in servizio al momento.
       
       ```
    - ./problema3.sh -io [BADGE] → Gestisce il check-in/check-out; calcola automaticamente il ritardo se l'ingresso supera le 08:00.
       ```
      ⚠️ Ritardo: 838 min.
      🟢 Badge 1023 → IN (21:58)
      ------------------------------------------------------------------
      🔴 Badge 1023 → OUT (21:58) - Ore: 0.00
       
       ```
    - ./problema3.sh -r [BADGE]→ Report analitico dei ritardi accumulati per singolo dipendente.
       ```
         Analisi Ritardi per Badge: 1023
        -------------------------------------------
        Giorno: 2026-01-24 | Entrata: 08:00 | ✅ PUNTUALE
        Giorno: 2026-01-26 | Entrata: 08:37 | ⚠️ RITARDO: 37 min
        Giorno: 2026-01-27 | Entrata: 08:00 | ✅ PUNTUALE
        Giorno: 2026-02-01 | Entrata: 08:00 | ✅ PUNTUALE
        Giorno: 2026-02-03 | Entrata: 08:36 | ⚠️ RITARDO: 36 min
        Giorno: 2026-02-04 | Entrata: 08:00 | ✅ PUNTUALE
        Giorno: 2026-02-05 | Entrata: 08:00 | ✅ PUNTUALE
        Giorno: 2026-02-18 | Entrata: 08:00 | ✅ PUNTUALE
        Giorno: 2026-02-19 | Entrata: 08:00 | ✅ PUNTUALE
        Giorno: 2026-02-20 | Entrata: 08:00 | ✅ PUNTUALE
        Giorno: 2026-02-21 | Entrata: 08:14 | ⚠️ RITARDO: 14 min
        Giorno: 2026-02-22 | Entrata: 21:58 | ⚠️ RITARDO: 838 min
       
       ```
    - ./problema3.sh -date [YYYY-MM-DD] → Riepilogo presenze collettivo per una data specifica con calcolo delle ore lavorate.
       ```
         Report dipendenti per il giorno: 2026-02-20
        --------------------------------------------------------------
        BADGE    | IN    | OUT   | ORE    | STATO RITARDO
        --------------------------------------------------------------
        1041     | 08:27 | 12:27 | 4.00   | Ritardo (27 min)
        1026     | 08:00 | 17:00 | 9.00   | OK
        1024     | 08:00 | 16:00 | 8.00   | OK
        1023     | 08:00 | 17:00 | 9.00   | OK
        1043     | 08:00 | 13:00 | 5.00   | OK
       
       ```
    - ./problema3.sh -s [BADGE] → Audit completo dello storico timbrature per il badge indicato.
       ```
         Storico Badge 1023
        1023    OUT     08:00   15:00   7.00    2026-01-24
        1023    OUT     08:37   15:37   7.00    2026-01-26
        1023    OUT     08:00   13:00   5.00    2026-01-27
        1023    OUT     08:00   16:00   8.00    2026-02-01
        1023    OUT     08:36   13:36   5.00    2026-02-03
        1023    OUT     08:00   13:00   5.00    2026-02-04
        1023    OUT     08:00   13:00   5.00    2026-02-05
        1023    OUT     08:00   16:00   8.00    2026-02-06
        1023    OUT     08:00   16:00   8.00    2026-02-14
        1023    OUT     08:00   15:00   7.00    2026-02-15
        1023    OUT     08:00   14:00   6.00    2026-02-18
        1023    OUT     08:00   13:00   5.00    2026-02-19
        1023    OUT     08:00   17:00   9.00    2026-02-20
        1023    OUT     08:14   14:14   6.00    2026-02-21
        1023    OUT     21:58   21:58   0.00    2026-02-22
       
       ```
    - ./problema3.sh -d [BADGE] [DATA] → Estrazione puntuale di una timbratura incrociando codice utente e calendario.
       ```
      1023    OUT     08:00   17:00   9.00    2026-02-20 

       
       ```
4.	Output: Visualizzazione organizzata in tabelle strutturate per il monitoraggio amministrativo.






