#!/bin/bash
# Indica al sistema che il file deve essere eseguito usando l'interprete Bash.

# ==========================================================
# SCRIPT: sensore_baita_multiplo.sh
# ==========================================================

# --- CONFIGURAZIONE FILE ---
DATABASE="gestione_tir.txt"       # Definisce il nome del file che contiene i dati dei TIR.
LOG_OUT="log_sensore.txt"         # Nome del file dove verranno scritti i log delle operazioni.
INVENTARIO="inventario_totale.txt" # Nome del file che memorizza il numero totale di pacchi.

# Variabili di stato iniziale
DATA_TARGET=$(date +"%Y-%m-%d")   # Imposta la data corrente come target predefinito (formato AAAA-MM-GG).
DATA_FINE=""                      # Inizializza la variabile per la data di fine (usata per i range).
MODALITA_REPORT=false              # Flag per capire se l'utente vuole un report testuale.
MODALITA_RANGE=false               # Flag per capire se la ricerca è tra due date.
MODALITA_MAX=false                 # Flag per la ricerca del TIR con più pacchi.

# --- GESTIONE PARAMETRI ---
# Legge le opzioni passate al comando (d richiede un argomento, g e M no).
while getopts "d:gM" opt; do
  case $opt in
    d) DATA_TARGET=$OPTARG; MODALITA_REPORT=true ;; # Imposta la data specificata e attiva il report.
    g) MODALITA_RANGE=true; MODALITA_REPORT=true ;; # Attiva la modalità intervallo di date.
    M) MODALITA_MAX=true; MODALITA_REPORT=true ;;   # Attiva la ricerca del record massimo.
    *) echo "Uso: $0 [-d data] [-g inizio fine] [-M inizio (fine)]"; exit 1 ;; # Errore in caso di opzione ignota.
  esac
done

# Rimuove le opzioni elaborate dalla lista degli argomenti ($1, $2, ecc.).
shift $((OPTIND-1))

# Recupero date extra per range o record massimo
if [ "$MODALITA_RANGE" = true ] || [ "$MODALITA_MAX" = true ]; then
    DATA_TARGET=$1 # Prima data dopo il flag (inizio).
    DATA_FINE=$2   # Seconda data dopo il flag (fine).
    if [ -z "$DATA_TARGET" ]; then # Controllo se manca la data obbligatoria.
        echo "Errore: Inserire almeno una data dopo il flag."
        exit 1
    fi
fi

# --- 1. FUNZIONE REPORT E RICERCA RECORD ---
if [ "$MODALITA_REPORT" = true ]; then
    if [ ! -f "$DATABASE" ]; then echo "❌ Errore: $DATABASE non trovato."; exit 1; fi # Esce se il DB non esiste.

    # Definisce una logica AWK per filtrare i dati basandosi sul formato JJ889SF-384-2026-02-21.
    AWK_FILTER='{
        split($1, a, "-"); dr = a[3]"-"a[4]"-"a[5]; # Taglia la prima parola ed estrae la data (parti 3,4,5).
        if (fine != "") { if (dr >= inizio && dr <= fine) print $0; } # Filtra per intervallo se definita una fine.
        else { if (dr == inizio) print $0; } # Altrimenti filtra per data singola.
    }'

    # Esegue awk passando le variabili di shell (inizio e fine) e salva i risultati.
    TIRI_FILTRATI=$(awk -v inizio="$DATA_TARGET" -v fine="$DATA_FINE" "$AWK_FILTER" "$DATABASE")

    if [ -z "$TIRI_FILTRATI" ]; then # Se la variabile è vuota, non ci sono dati.
        echo "ℹ️ Nessun record trovato per i criteri inseriti."
        exit 0
    fi

    # --- SOTTO-CASO: RICERCA DEL MASSIMO (-M) ---
    if [ "$MODALITA_MAX" = true ]; then
        echo "🏆 RICERCA TIR RECORD (TOP CARICO)"
        [ -n "$DATA_FINE" ] && echo "Periodo: $DATA_TARGET / $DATA_FINE" || echo "Data: $DATA_TARGET"
        echo "-------------------------------------------------------"
        
        # Ordina per il secondo campo del separatore "-" (i pacchi) in modo numerico (n) e inverso (r).
        RECORD=$(echo "$TIRI_FILTRATI" | sort -t'-' -k2,2nr | head -n 1)
        
        INFO_REC=$(echo "$RECORD" | awk '{print $1}') # Prende la prima colonna (Targa-Pacchi-Data).
        ORA_REC=$(echo "$RECORD" | awk '{print $2}')  # Prende la seconda colonna (Ora).
        TARGA_REC=$(echo "$INFO_REC" | cut -d'-' -f1) # Estrae la targa.
        PACCHI_REC=$(echo "$INFO_REC" | cut -d'-' -f2) # Estrae il numero di pacchi.
        DATA_REC=$(echo "$INFO_REC" | cut -d'-' -f3,4,5) # Estrae la data.

        echo "🥇 IL TIR PIÙ CARICO TROVATO:"
        echo "🚛 Targa:   $TARGA_REC"
        echo "📦 Pacchi:  $PACCHI_REC"
        echo "📅 Data:    $DATA_REC ore $ORA_REC"
        exit 0 # Chiude lo script dopo aver mostrato il record.
    fi

    # --- SOTTO-CASO: REPORT STANDARD (-d o -g) ---
    echo "📊 REPORT GESTIONALE TIR"
    echo "-------------------------------------------------------"
    printf "%-12s | %-12s | %-8s | %-6s\n" "DATA" "TARGA" "PACCHI" "ORA" # Formatta l'intestazione.
    echo "-------------------------------------------------------"
    
    TOT_P=0; CONTEGGIO=0 # Inizializza i totalizzatori a zero.
    while read -r riga; do # Ciclo per elaborare ogni riga trovata.
        COL1=$(echo "$riga" | awk '{print $1}') # Prima colonna (Dati TIR).
        ORA=$(echo "$riga" | awk '{print $2}')  # Seconda colonna (Ora).
        TARGA=$(echo "$COL1" | cut -d'-' -f1)   # Estrazione targa.
        PACCHI=$(echo "$COL1" | cut -d'-' -f2)  # Estrazione pacchi.
        D_RIGA=$(echo "$COL1" | cut -d'-' -f3,4,5) # Estrazione data.

        printf "%-12s | %-12s | %-8s | %-6s\n" "$D_RIGA" "$TARGA" "$PACCHI" "$ORA" # Stampa riga tabella.
        
        TOT_P=$((TOT_P + PACCHI))    # Addiziona i pacchi al totale.
        CONTEGGIO=$((CONTEGGIO + 1)) # Conta i TIR trovati.
    done <<< "$TIRI_FILTRATI"
    
    echo "-------------------------------------------------------"
    echo "📈 RIASSUNTO:"
    echo "🚛 Numero totale TIR: $CONTEGGIO"
    echo "📦 Totale pacchi scaricati: $TOT_P"
    exit 0 # Chiude lo script.
fi

# --- 2. MODALITÀ REAL-TIME (Simulazione) ---
echo "📡 SISTEMA MONITORAGGIO ATTIVO"
# Crea 3 array per gestire le 3 baite contemporaneamente (Targa, Timer scarico, N. pacchi).
declare -a baita_targa=("" "" "")
declare -a baita_timer=(0 0 0)
declare -a baita_pacchi=(0 0 0)

# Crea il file inventario se non esiste, partendo da zero.
[ ! -f "$INVENTARIO" ] && echo "0" > "$INVENTARIO"

while true; do # Inizia un ciclo infinito per simulare il tempo.
    ORA_ATTUALE=$(date +"%H:%M") # Legge l'ora del sistema.
    DATA_ORA_LOG=$(date +"%Y-%m-%d-%H:%M") # Stringa completa per il file di log.

    # Cerca nel DB se ci sono TIR che devono arrivare esattamente a quest'ora.
    arrivi_ora=$(grep "$DATA_TARGET $ORA_ATTUALE" "$DATABASE")

    if [ ! -z "$arrivi_ora" ]; then # Se ci sono nuovi arrivi...
        while read -r riga; do # ...li processa uno per uno.
            COL1=$(echo "$riga" | awk '{print $1}')
            targa=$(echo "$COL1" | cut -d'-' -f1)
            pacchi=$(echo "$COL1" | cut -d'-' -f2)
            
            # Controlla se il TIR è già presente in una baita (evita duplicati).
            gia_presente=false
            for j in {0..2}; do [[ "${baita_targa[$j]}" == "$targa" ]] && gia_presente=true; done

            if [ "$gia_presente" = false ]; then
                for i in {0..2}; do # Cerca una baita libera (vuota).
                    if [ -z "${baita_targa[$i]}" ]; then
                        baita_targa[$i]=$targa # Occupa la baita.
                        baita_pacchi[$i]=$pacchi # Registra i pacchi.
                        baita_timer[$i]=$(( ( RANDOM % 3 ) + 3 )) # Imposta timer casuale tra 3 e 5 minuti.
                        echo "[$ORA_ATTUALE] 🚛 ENTRATA B$((i+1)): $targa ($pacchi pacchi)"
                        break # Esci dal ciclo baita (TIR sistemato).
                    fi
                done
            fi
        done <<< "$arrivi_ora"
    fi

    STATO_V="" # Inizializza la stringa per mostrare lo stato delle baite a video.
    for i in {0..2}; do # Ciclo di aggiornamento per ogni baita.
        if [ ! -z "${baita_targa[$i]}" ]; then # Se la baita è occupata...
            STATO_V="$STATO_V [B$((i+1)):${baita_targa[$i]}]"
            ((baita_timer[$i]--)) # Decrementa il timer di un minuto.
            if [ "${baita_timer[$i]}" -le 0 ]; then # Se il timer arriva a zero, il TIR esce.
                TOT_PREC=$(cat "$INVENTARIO") # Legge l'inventario attuale.
                echo "$((TOT_PREC + baita_pacchi[$i]))" > "$INVENTARIO" # Aggiunge i pacchi e salva.
                echo "[$ORA_ATTUALE] ✅ USCITA B$((i+1)): ${baita_targa[$i]}"
                baita_targa[$i]="" # Svuota la baita.
            fi
        else
            STATO_V="$STATO_V [B$((i+1)):vuoto]" # Se è libera, scrive vuoto.
        fi
    done

    # Costruisce la riga di log e la scrive nel file.
    LOG_LINE="$DATA_ORA_LOG"
    for t in "${baita_targa[@]}"; do
        [ -z "$t" ] && LOG_LINE="$LOG_LINE-vuoto" || LOG_LINE="$LOG_LINE-$t"
    done
    echo "$LOG_LINE" >> "$LOG_OUT"

    # Mostra lo stato aggiornato a video.
    echo "[$ORA_ATTUALE]$STATO_V | Magazzino: $(cat "$INVENTARIO") pacchi"
    sleep 60 # Sospende lo script per un minuto prima del prossimo aggiornamento.
done
