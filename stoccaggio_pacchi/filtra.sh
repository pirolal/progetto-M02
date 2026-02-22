#!/bin/bash
# La riga sopra è la "Shebang": indica al sistema di usare l'interprete Bash per eseguire lo script.

# ==========================================================
# SCRIPT: filtra.sh
# CONTESTO: Gestione Logistica e Business Intelligence
# DESCRIZIONE: Analisi dei flussi di magazzino e performance
# ==========================================================

FILE="magazzino.txt"  # Assegna il nome del file di database a una variabile per poterlo richiamare facilmente.

# --- FASE 1: CONTROLLO INTEGRITÀ ---
# L'operatore [ ! -f "$FILE" ] verifica se il file NON esiste o non è un file regolare.
if [ ! -f "$FILE" ]; then
    echo "Errore: File non trovato." # Messaggio di errore per l'utente.
    exit 1 # Esci dallo script con un codice di errore (1).
fi

# --- FASE 2: INIZIALIZZAZIONE VARIABILI ---
# Prepariamo le variabili vuote o con valori predefiniti per evitare conflitti.
MATRICOLA=""
DATA_SINGOLA=""
DATA_INIZIO=""
DATA_FINE=""
RANGE=false # Variabile booleana per capire se l'utente vuole un intervallo di date.
TROVA_MAX=false # Variabile booleana per attivare la funzione "Top Performer".
OGGI=$(date +%Y-%m-%d) # Esegue il comando 'date' e salva la data attuale nel formato Anno-Mese-Giorno.

# --- FASE 3: PARSING PARAMETRI (GETOPTS) ---
# 'getopts' analizza i parametri passati (es: -m 001). I due punti dopo 'm' e 'd' indicano che richiedono un valore.
while getopts "m:d:gM" opt; do
  case $opt in
    m) MATRICOLA="$OPTARG" ;;   # Salva l'argomento passato dopo -m nella variabile MATRICOLA.
    d) DATA_SINGOLA="$OPTARG" ;; # Salva l'argomento passato dopo -d nella variabile DATA_SINGOLA.
    g) RANGE=true ;;             # Se presente -g, imposta la variabile RANGE su vero.
    M) TROVA_MAX=true ;;         # Se presente -M, imposta la variabile TROVA_MAX su vero.
    *) echo "Uso: $0 [-m matricola] [-d data] [-g data1 data2] [-M]"; exit 1 ;; # Se viene usata un'opzione sconosciuta.
  esac
done

# 'shift' sposta il puntatore dei parametri. Rimuove le opzioni processate (-m, -d, ecc.) dalla lista dei parametri.
shift $((OPTIND-1)) 

# Se RANGE è vero, leggiamo i parametri rimanenti (posizionali) come data inizio e fine.
if [ "$RANGE" = true ]; then
    DATA_INIZIO=$1 # Primo parametro dopo le opzioni.
    DATA_FINE=$2   # Secondo parametro dopo le opzioni.
fi

# --- FASE 4: FUNZIONE SOMMA_PACCHI ---
# Definiamo una funzione riutilizzabile per sommare i pacchi estratti dai log.
somma_pacchi() {
    # Usiamo 'awk' impostando il trattino '-' come separatore di campo (-F).
    awk -F'-' '{
        for(i=1;i<=NF;i++) {                # Cicla attraverso tutti i campi della riga (NF = numero di campi).
            if($i ~ /totalepacchi/) {       # Se il campo contiene la parola 'totalepacchi'.
                split($i, a, ":");          # Divide il campo (es: totalepacchi:10) usando i due punti ':'.
                sum += a[2]                 # Aggiunge il valore numerico (10) alla variabile sum.
            }
        }
    } END { print sum+0 }'                  # Alla fine della lettura, stampa il totale. Il '+0' assicura un output numerico anche se vuoto.
}

# --- CASO DEFAULT: SE LANCIATO SENZA PARAMETRI ---
# Controlla se tutte le variabili di ricerca sono vuote/false.
if [ -z "$MATRICOLA" ] && [ -z "$DATA_SINGOLA" ] && [ "$RANGE" = false ] && [ "$TROVA_MAX" = false ]; then
    echo "--- Situazione Magazzino Oggi ($OGGI) ---"
    
    # 'grep' cerca tutte le righe del file che contengono la data di oggi.
    BLOCK=$(grep "Data:$OGGI" "$FILE")

    if [ -z "$BLOCK" ]; then
        echo "Nessun dato registrato per oggi ($OGGI)."
    else
        # Passa il contenuto di BLOCK alla funzione somma_pacchi.
        TOT_OGGI=$(echo "$BLOCK" | somma_pacchi)
        echo "TOTALE PACCHI OGGI: $TOT_OGGI"
        echo "-----------------------------------"
        echo "Dettaglio per matricola:"
        # 'cut' estrae la parte 'matricola:X', 'sort' ordina e 'uniq' rimuove i duplicati per avere l'elenco dei dipendenti attivi.
        echo "$BLOCK" | cut -d'-' -f1 | cut -d':' -f2 | sort | uniq | while read m; do
            # Per ogni matricola trovata (m), calcola il suo totale specifico.
            TOT_M=$(echo "$BLOCK" | grep "matricola:$m-" | somma_pacchi)
            echo "- Matricola $m: $TOT_M pacchi"
        done
    fi
    exit 0 # Esci con successo.
fi

# --- CASO 1: RICERCA DEL MASSIMO (-M) ---
if [ "$TROVA_MAX" = true ]; then
    TEMP_LIST=$(mktemp) # Crea un file temporaneo unico per non sporcare il sistema.
    
    if [ "$RANGE" = true ]; then
        echo "--- Record nel periodo: $DATA_INIZIO / $DATA_FINE ---"
        # 'awk' filtra le righe dove il secondo campo dopo 'Data:' è compreso tra le date specificate.
        cat "$FILE" | awk -F'Data:' -v inizio="$DATA_INIZIO" -v fine="$DATA_FINE" '$2 >= inizio && $2 <= fine' > "$TEMP_LIST.range"
    else
        echo "--- Record nel giorno: $DATA_SINGOLA ---"
        grep "Data:$DATA_SINGOLA" "$FILE" > "$TEMP_LIST.range"
    fi

    # Analizziamo i dati filtrati per calcolare il totale di ogni singola matricola.
    cat "$TEMP_LIST.range" | cut -d'-' -f1 | cut -d':' -f2 | sort | uniq | while read m; do
        TOT=$(grep "matricola:$m-" "$TEMP_LIST.range" | somma_pacchi)
        echo "$m $TOT" >> "$TEMP_LIST.risultati" # Salva "Matricola Totale" nel file temporaneo.
    done

    # 'awk' legge il file dei risultati e trova il valore massimo nella seconda colonna ($2).
    MAX_VAL=$(awk '{if($2>max) max=$2} END {print max}' "$TEMP_LIST.risultati" 2>/dev/null)

    if [ -z "$MAX_VAL" ] || [ "$MAX_VAL" -eq 0 ]; then
        echo "Nessun dato trovato."
    else
        echo "Record di pacchi sparati: $MAX_VAL 🏆"
        echo "Raggiunto da:"
        # Cerca nel file chi ha raggiunto esattamente quel valore massimo (gestisce eventuali pareggi).
        awk -v m="$MAX_VAL" '$2 == m {print "- Matricola: " $1}' "$TEMP_LIST.risultati"
    fi
    rm -f "$TEMP_LIST"* # Cancella tutti i file temporanei creati.
    exit 0
fi

# --- CASO 2: RANGE SENZA MATRICOLA (-g data1 data2) ---
if [ "$RANGE" = true ] && [ -z "$MATRICOLA" ]; then
    echo "--- Report Totale Periodo ($DATA_INIZIO / $DATA_FINE) ---"

    # Filtra il file magazzino.txt per l'intervallo di date indicato.
    BLOCK=$(awk -F'Data:' -v inizio="$DATA_INIZIO" -v fine="$DATA_FINE" \
        '$2 >= inizio && $2 <= fine' "$FILE")

    if [ -z "$BLOCK" ]; then
        echo "Nessun dato nel periodo."
    else
        echo "Totale pacchi nel periodo: $(echo "$BLOCK" | somma_pacchi)"
        echo "-----------------------------------"
        echo "Dettaglio per matricola:"
        # Genera il riepilogo per ogni dipendente nel periodo selezionato.
        echo "$BLOCK" | cut -d'-' -f1 | cut -d':' -f2 | sort | uniq | while read m; do
            TOT_M=$(echo "$BLOCK" | grep "matricola:$m-" | somma_pacchi)
            echo "- Matricola $m: $TOT_M pacchi"
        done
    fi
    exit 0
fi

# --- CASO 3: RANGE PER MATRICOLA (-m x -g data1 data2) ---
if [ "$RANGE" = true ] && [ -n "$MATRICOLA" ]; then
    echo "--- Report Matricola $MATRICOLA ($DATA_INIZIO / $DATA_FINE) ---"
    # Cerca prima la matricola e poi filtra per data tramite awk.
    BLOCK=$(grep "matricola:$MATRICOLA-" "$FILE" | awk -F'Data:' -v inizio="$DATA_INIZIO" -v fine="$DATA_FINE" '$2 >= inizio && $2 <= fine')
    
    if [ -z "$BLOCK" ]; then echo "Nessun dato."; else
        # Cicla sulle date uniche trovate per quel dipendente nel periodo.
        echo "$BLOCK" | awk -F'Data:' '{print $2}' | sort | uniq | while read d; do
            P=$(echo "$BLOCK" | grep "Data:$d" | somma_pacchi)
            echo "Data: $d | Pacchi: $P"
        done
        # Calcola il totale complessivo finale (TOTALONE).
        echo "TOTALONE: $(echo "$BLOCK" | somma_pacchi)"
    fi

# --- CASO 4: SOLO DATA (-d y) ---
# Utilizzato se viene passata solo l'opzione -d (senza -m o -g).
elif [ -n "$DATA_SINGOLA" ] && [ -z "$MATRICOLA" ]; then
    echo "--- Report del $DATA_SINGOLA ---"
    # Estrae tutte le matricole che hanno lavorato in quella data specifica.
    grep "Data:$DATA_SINGOLA" "$FILE" | cut -d'-' -f1 | cut -d':' -f2 | sort | uniq | while read m; do
        TOT_M=$(grep "matricola:$m-" "$FILE" | grep "Data:$DATA_SINGOLA" | somma_pacchi)
        echo "Matricola $m: $TOT_M pacchi"
    done

# --- CASO 5: SOLO MATRICOLA (-m x) ---
# Utilizzato se viene passata solo la matricola (senza -d o -g). Mostra l'intera storia del dipendente.
elif [ -n "$MATRICOLA" ]; then
    echo "--- Carriera Matricola $MATRICOLA ---"
    # Identifica tutte le date in cui questa matricola compare nel log.
    grep "matricola:$MATRICOLA-" "$FILE" | awk -F'Data:' '{print $2}' | sort | uniq | while read d; do
        # Calcola i pacchi giorno per giorno.
        TOT_G=$(grep "matricola:$MATRICOLA-" "$FILE" | grep "Data:$d" | somma_pacchi)
        echo "$d: $TOT_G pacchi"
    done
    # Mostra la somma totale di tutti i pacchi lavorati da sempre.
    echo "TOTALONE CARRIERA: $(grep "matricola:$MATRICOLA-" "$FILE" | somma_pacchi)"
fi
