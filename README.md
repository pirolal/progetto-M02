# progetto magazzino di simistamento

![immagine magazzino](https://github.com/user-attachments/assets/30e5e9d6-5495-4f3c-a050-a59da9d4cb9d)

## problema 1: Monitoraggio Baie di Scarico (Indact)
### Script: ./sensore_baita_multiplo.sh
Gestisce la prima fase del processo logistico: l'arrivo dei TIR e lo scarico dei pacchi nelle 3 baie del magazzino. Lo script si interfaccia con un sistema di sensori e telecamere (simulato tramite input Python)



## problema 2: Monitoraggio produttività dei dipendenti
### Script: 





## problema 3: Fondo rullo
### Script: 







## problema 4: Gestione Assenze e sostituzioni dei corrieri
### Script: 





## problema 5:  Tracciabilità Totale Smistamento

### Script: 




## problema 6: Monitoraggio e Archiviazione Certificata
### Script: 
#### Soluzione proposta e funzionamento:

#### Manuale Operativo:




## problema 7: Smarrimento pacchi durante il trasporto
### Script: 
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
### Script: 
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
### Script: 
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
### Script: 
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
