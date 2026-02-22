# progetto magazzino di simistamento

![immagine magazzino](https://github.com/user-attachments/assets/30e5e9d6-5495-4f3c-a050-a59da9d4cb9d)

## problema 1: Monitoraggio Baie di Scarico (Indact)
### Script: ./sensore_baita_multiplo.sh
#### Soluzione proposta e funzionamento:
Il sistema monitora costantemente le 3 baie di scarico tramite sensori e telecamere. Lo script Bash agisce in ascolto leggendo l'input da un modulo Python che genera dati casuali su targhe, orari e numero di pacchi. Permette di visualizzare lo stato live delle baie o di consultare lo storico per identificare i volumi di carico e i TIR arrivati.


#### Manuale Operativo:
● Monitoraggio LIVE: ./sensore_baita_multiplo.sh (mostra lo stato attuale delle baie B1, B2, B3).
● Storico Giornaliero: ./sensore_baita_multiplo.sh -d [data] (es: 2026-02-22).
● Comparazione Periodo: ./sensore_baita_multiplo.sh -g [data_inizio] [data_fine].
● Ricerca Record: ./sensore_baita_multiplo.sh -M [data] (mostra il TIR più carico del giorno).



## problema 2: Monitoraggio produttività dei dipendenti
### Script: ./filtra.sh
#### Soluzione proposta e funzionamento:
Lo script monitora lo stoccaggio dei pacchi per ogni dipendente. Permette di verificare il rendimento giornaliero, analizzare la "carriera" lavorativa di una specifica matricola o individuare chi ha stabilito il record di pacchi stoccati (sparati) in un determinato arco temporale.


#### Manuale Operativo:
● Situazione Odierna: ./filtra.sh (mostra il totale pacchi e il dettaglio per matricola di oggi).
● Carriera Dipendente: ./filtra.sh -m [matricola] (es: 02).
● Report Data Specifica: ./filtra.sh -d [data].
● Report Periodo: ./filtra.sh -g [data1] [data2].
● Ricerca Record: ./filtra.sh -M (può essere unito a -d o -g per trovare il recordman di quel periodo).


## problema 3: Fondo rullo
### Script: ./rinvsens.sh
#### Soluzione proposta e funzionamento:
Monitora la parte finale del sistema di smistamento automatico. Un sensore rileva ogni 2 secondi l'altezza dei pacchi nel carrello; al raggiungimento della soglia critica di 100 cm, invia automaticamente un messaggio al device di un operatore per lo svuotamento, garantendo la continuità del flusso.


#### Manuale Operativo:
● Monitoraggio LIVE: ./rinvsens.sh (mostra l'altezza in tempo reale e attiva gli alert).
● Analisi Giorno Singolo: ./rinvsens.sh -d [data] (conta quante volte la soglia è stata superata).
● Analisi Intervallo: ./rinvsens.sh -g [inizio] [fine].



## problema 4: Gestione Assenze e sostituzioni dei corrieri
### Script: ./contatta_corrieri.sh
#### Soluzione proposta e funzionamento:
Il sistema automatizza il protocollo di emergenza. Esegue un appello digitale istantaneo,
rileva le mancanze e attinge immediatamente a un database di riserva. Attraverso una
simulazione di contatto intelligente, il software assegna i sostituti in tempo reale, garantendo
che ogni mattina l'organico sia sempre di 20 operatori su 20, annullando i tempi morti di
coordinamento.


#### Manuale Operativo:
File principale: contatta_corrieri.sh
● Comando: ./contatta_corrieri.sh
● Logica: Lo script avvia il modulo Python generatore_assenti.py per l'appello. Se
vengono rilevati assenti, lo script Bash avvia una scansione ricorsiva sul database
corrieri.csv finché non trova e conferma i sostituti necessari.
● Output: Genera un report ufficiale denominato registro_assenti.txt per le finalità
amministrative.



## problema 5:  Tracciabilità Totale Smistamento
### Script: ./Simulatore.sh
#### Soluzione proposta e funzionamento:
Il Simulatore Smistamento Smart elimina l'incertezza. Ogni pacco che entra nel sistema
viene registrato in un database SQLite e indirizzato digitalmente a un sensore specifico.
Questo crea un legame indissolubile tra il pacco, il cliente e la sua posizione fisica nel
magazzino. In ogni istante, l'operatore può interrogare il sistema per sapere esattamente
quale sensore ha processato un collo, azzerando gli smarrimenti interni.


#### Manuale Operativo:
File principali: Simulatore.sh (interfaccia CLI) e gestione_spedizioni.db (database).
● Inizializzazione: ./Simulatore.sh -i (Popola il database e avvia il flusso di smistamento
automatico).
● Filtro per Area: ./Simulatore.sh -s1 (oppure -s2, -s3) per visualizzare l'elenco dei
pacchi presenti in una specifica zona di carico.
● Ricerca Puntuale: ./Simulatore.sh -p [ID] per ottenere il percorso esatto e il sensore
di passaggio di un determinato pacco.



## problema 6: Monitoraggio e Archiviazione Certificata
### Script: ./Accensione_Server.sh
#### Soluzione proposta e funzionamento:
Il monitoraggio è stato trasformato in un sistema di auditing automatico. Grazie a un server
Node.js, ogni volta che viene aperta la dashboard web per visualizzare le telecamere, il
sistema scatta automaticamente uno screenshot di tutti i sensori. Queste immagini vengono
archiviate in un database fisico organizzato per Anno, Mese, Giorno e Ora, creando uno
storico inalterabile che documenta lo stato del magazzino a ogni singolo accesso.


#### Manuale Operativo:
File principali: Accensione_Server.sh e server.js.
● Avvio: Eseguire ./Accensione_Server.sh per attivare il server sulla porta 9000.
● Utilizzo: Accedere tramite browser all'indirizzo http://localhost:9000.
● Automazione: All'apertura della pagina index.html, il sistema invia i segnali al server
che provvede a creare la struttura delle cartelle, salvare i file JPG e aggiornare il
registro cronologico report_accesso.csv.



## problema 7: Smarrimento pacchi durante il trasporto
### Script: ./problema10.sh
#### Soluzione proposta e funzionamento:
La soluzione prevede l’implementazione di un database centralizzato in cui vengono registrati tutti i pacchi che devono arrivare al magazzino, trasformando il sistema da reattivo a proattivo. Il sistema funziona in questo modo:
1.	Ogni pacco ritirato viene inserito nel database con: ID univoco, email del mittente, email del cliente, descrizione del contenuto e stato (atteso / arrivato).
2.	Uno script automatico confronta periodicamente l’elenco dei pacchi attesi con quelli effettivamente registrati all’arrivo.
3.	Se viene rilevata un’anomalia (pacco non arrivato nei tempi previsti):
  o	Viene inviata automaticamente un’email al trasportatore per sollecitare il tracciamento.
  o	Viene informato il cliente con una comunicazione di cortesia, anticipando il suo possibile reclamo.
Inoltre, il sistema permette di filtrare i pacchi, monitorare lo stato in tempo reale e garantire una tracciabilità totale che previene le "zone d'ombra" nel trasporto.


#### Manuale Operativo:
Questo modulo gestisce l'acquisizione in tempo reale dei dati provenienti dai sensori dei rulli.
1.	Abilitazione: Per prima cosa, rendiamo eseguibili i due script tramite il comando chmod u+x problema1.sh problema1.2.sh.
2.	Esecuzione: Avviamo il sistema tramite ./problema1.sh. Questo comando agisce da orchestratore, lanciando in background 3 istanze parallele del modulo problema1.2.sh.
3.	Logica Operativa: Ogni istanza interroga un algoritmo stocastico Python (generatore.py) per simulare il carico sui rulli. Il sistema è programmato per essere operativo esclusivamente nella fascia oraria 08:00 - 22:00.
4.	Output: Vengono generati log cronologici nella cartella log_peso/, categorizzati per data e numero di tela (es: log_2026-02-22_tela1.log).
5.	Terminazione: Per arrestare il monitoraggio e chiudere in sicurezza tutti i processi attivi, utilizzare la combinazione di tasti CTRL+C.



## problema 8: Sovraccarico delle tele di smistamento
### Script: ./problema1.sh ./problema1.2.sh 
#### Soluzione proposta e funzionamento:
La soluzione prevede l’installazione di un sensore di peso su ciascuna delle tre tele, creando un sistema di sicurezza intelligente (fail-safe). Il sistema utilizza due soglie operative:
•	300 kg → Soglia di attenzione: attivazione di un LED di avviso. Il dipendente viene avvisato visivamente e può iniziare lo svuotamento senza che la linea si fermi.
•	500 kg → Soglia critica: isolamento automatico della tela dal rullo centrale. Il flusso si interrompe temporaneamente per salvaguardare l'integrità del macchinario e la sicurezza del personale.
L'intero processo viene monitorato da due script che registrano in tre file di log separati ogni evento (peso, stato LED, isolamento). Questo garantisce non solo prevenzione immediata, ma anche una memoria storica per la manutenzione.


#### Manuale Operativo:
Questo modulo processa i log generati dal Modulo 1 per estrarre statistiche di fermo macchina.
1.	Abilitazione: Rendere eseguibile lo script tramite chmod u+x problema2.sh.
2.	Sintassi e Parametri: L'analisi si adatta dinamicamente agli argomenti inseriti:
o	./problema2.sh → Analisi rapida dei blocchi avvenuti nella data odierna.
o	./problema2.sh [RULLO]→ Focus specifico sulle performance di una singola linea di produzione.
o	./problema2.sh [YYYY-MM-DD]→ Report giornaliero con calcolo dei secondi totali di fermo e dettaglio orario.
o	./problema2.sh [DATA] [ORARIO] [RULLO] → Analisi granulare filtrata per data, fascia oraria e macchinario.
o	./problema2.sh -c [DATA1] [DATA2] → Business Intelligence: confronta le due date e calcola la variazione percentuale di efficienza lavorativa.
3.	Output: I dati vengono processati e proiettati a terminale in formato testuale leggibile.



## problema 9: Analisi dell’andamento delle tele e produttività
### Script: ./problema2.sh
#### Soluzione proposta e funzionamento:
Abbiamo sviluppato uno script di analisi generalizzato che elabora i dati dei file di log, trasformando i dati tecnici in indicatori strategici. Il sistema permette di:
•	Verificare la frequenza degli isolamenti delle tele e la durata delle interruzioni.
•	Analizzare il carico di lavoro in specifici intervalli orari per ottimizzare i turni del personale.
•	Effettuare confronti mensili o annuali, calcolando la variazione percentuale del volume gestito.
•	Identificare i "colli di bottiglia" strutturali su cui intervenire con nuovi investimenti.
Lo script restituisce statistiche pronte all'uso, permettendo una gestione aziendale basata sulla Business Intelligence.


#### Manuale Operativo:
Questo modulo gestisce l'anagrafica dinamica degli ingressi e delle uscite del personale.
1.	Abilitazione: Configurare i permessi tramite chmod u+x problema3.sh.
2.	Sintassi e Parametri:
  o	./problema3.sh → Visualizza istantaneamente il personale attualmente in servizio (Stato: IN).
  o	./problema3.sh -io [BADGE] → Gestisce il check-in/check-out; calcola automaticamente il ritardo se l'ingresso supera le 08:00.
  o	./problema3.sh -r [BADGE]→ Report analitico dei ritardi accumulati per singolo dipendente.
  o	./problema3.sh -date [YYYY-MM-DD] → Riepilogo presenze collettivo per una data specifica con calcolo delle ore lavorate.
  o	./problema3.sh -s [BADGE] → Audit completo dello storico timbrature per il badge indicato.
  o	./problema3.sh -d [BADGE] [DATA] → Estrazione puntuale di una timbratura incrociando codice utente e calendario.
3.	Output: Visualizzazione organizzata in tabelle strutturate per il monitoraggio amministrativo.



## problema 10: Controllo delle timbrature dei dipendenti
### Script: ./problema3.sh
#### Soluzione proposta e funzionamento:
La soluzione consiste nello sviluppo di uno script di gestione delle timbrature collegato a un database delle presenze sicuro e trasparente. Il sistema consente di:
1.	Automatizzare la registrazione: orario di entrata, uscita e calcolo immediato dei ritardi.
2.	Supportare la contabilità: i commercialisti possono visualizzare lo storico e calcolare le ore lavorate tramite un comando dedicato, riducendo a zero l'errore umano.
3.	Fornire strumenti decisionali: il datore di lavoro può verificare chi ha lavorato in una certa data, monitorare la frequenza dei ritardi e prendere decisioni contrattuali basate su dati oggettivi.
Il sistema garantisce precisione e trasparenza, migliorando il clima aziendale e l'efficienza burocratica.


#### Manuale Operativo:
Questo modulo automatizza il tracciamento dei pacchi e le comunicazioni ai clienti.
1.	Abilitazione: Rendere eseguibile il file tramite chmod u+x problema4.sh.
2.	Sintassi e Parametri:
  o	./problema4.sh → Elenco generale della merce con stato di giacenza (In magazzino / In transito).
  o	./problema4.sh -t → Mostra solo i pacchi già pervenuti correttamente (Stato: DENTRO).
  o	./problema4.sh -f → Mostra solo le mancanze e i pacchi ancora non arrivati (Stato: FUORI).
  o	./problema4.sh -i → Report descrittivo dettagliato del contenuto di ogni collo tramite ID.
  o	./problema4.sh -e → Automazione Notifiche: attiva l'invio massivo di email. Invia solleciti ai fornitori e avvisi di ritardo ai clienti finali.
3.	User Experience: L'interfaccia terminale include barre di avanzamento grafiche che simulano il caricamento e l’invio dell’email  



progetto svolto da: Pirola Luca, Epis Tommaso, Neagu Andrei Angelo
