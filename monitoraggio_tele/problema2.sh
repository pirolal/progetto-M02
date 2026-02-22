#!/bin/bash

LOG_DIR="log_peso"
OGGI=$(date +%F)

# --- Funzione per normalizzare la data (es. da 2026-2-3 a 2026-02-03) ---
normalizza_data() {
    echo "$1" | awk -F- '{printf "%04d-%02d-%02d", $1, $2, $3}'
}

time_to_seconds() {
    IFS=: read -r HH MM SS <<< "$1"
    echo $((10#$HH*3600 + 10#$MM*60 + 10#$SS))
}

conta_eventi_blocco() {
    local DATA_RIF=$(normalizza_data "$1")
    # Cerchiamo i file usando il pattern con lo zero aggiunto
    local FILES=(${LOG_DIR}/log_${DATA_RIF}_tela*.log)
    local CONTEGGIO=0

    for FILE_LOG in "${FILES[@]}"; do
        if [ -f "$FILE_LOG" ]; then
            VOLTE=$(grep -c "tela bloccata" "$FILE_LOG")
            CONTEGGIO=$((CONTEGGIO + VOLTE))
        fi
    done
    echo "$CONTEGGIO"
}

# ---------------------------------------------------------
# Gestione Argomento -c (CONFRONTO DATE)
# ---------------------------------------------------------
if [ "$1" == "-c" ]; then
    if [ $# -ne 3 ]; then
        echo "Uso: $0 -c YYYY-MM-DD YYYY-MM-DD"
        exit 1
    fi
    
    # Normalizziamo gli input subito
    D1=$(normalizza_data "$2")
    D2=$(normalizza_data "$3")

    B1=$(conta_eventi_blocco "$D1")
    B2=$(conta_eventi_blocco "$D2")

    # Controllo se i file esistono o sono vuoti
    if [ "$B1" -eq 0 ] && [ "$B2" -eq 0 ]; then
        echo "Attenzione: 0 blocchi trovati per entrambe le date. Verifica che i file in $LOG_DIR esistano."
        exit 0
    fi

    if [ $B1 -eq $B2 ]; then
        echo "Il giorno $D1 l'azienda ha lavorato quanto il $D2 (Entrambi $B1 blocchi)."
    elif [ $B2 -eq 0 ]; then
        echo "Il giorno $D1 l'azienda ha lavorato meno del $D2 (Il giorno $D2 ha avuto 0 blocchi)."
    else
        if [ $B1 -lt $B2 ]; then
            DIFF=$((B2 - B1))
            PERC=$(( (DIFF * 100) / B2 ))
            echo "Il giorno $D1 l'azienda ha lavorato il $PERC% in più rispetto al $D2 (Blocchi: $D1=$B1, $D2=$B2)"
        else
            DIFF=$((B1 - B2))
            PERC=$(( (DIFF * 100) / B1 ))
            echo "Il giorno $D1 l'azienda ha lavorato il $PERC% in meno rispetto al $D2 (Blocchi: $D1=$B1, $D2=$B2)"
        fi
    fi
    exit 0
fi

# ---------------------------------------------------------
# Gestione argomenti STANDARD
# ---------------------------------------------------------
if [ $# -eq 3 ]; then
    DATA=$(normalizza_data "$1"); ORARIO_RANGE=$2; RULLO=$3
elif [ $# -eq 2 ]; then
    DATA=$(normalizza_data "$1"); ORARIO_RANGE="00:00-23:59"; RULLO=$2
elif [ $# -eq 1 ]; then
    if [[ $1 =~ ^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$ ]]; then
        DATA=$(normalizza_data "$1"); ORARIO_RANGE="00:00-23:59"; RULLO=""
    else
        DATA="$OGGI"; ORARIO_RANGE="00:00-23:59"; RULLO=$1
    fi
else
    DATA="$OGGI"; ORARIO_RANGE="00:00-23:59"; RULLO=""
fi

# Selezione file per calcolo standard
if [ -n "$RULLO" ]; then
    FILES=("${LOG_DIR}/log_${DATA}_tela${RULLO}.log")
else
    FILES=(${LOG_DIR}/log_${DATA}_tela*.log)
fi

INIZIO=${ORARIO_RANGE%-*}
FINE=${ORARIO_RANGE#*-}
SEC_FERMO=0
RIGHE_FERMI=""

for FILE_LOG in "${FILES[@]}"; do
    [ -f "$FILE_LOG" ] || continue
    FERMO_IN_CORSO=0
    TS_INIZIO_FERMO=0
    TS_SEC=0

    while IFS= read -r LINE; do
        TS=$(echo "$LINE" | sed -E 's/^\s*([0-9]{2}:[0-9]{2}:[0-9]{2}).*/\1/')
        [[ $TS =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]] || continue
        HHMM=${TS:0:5}
        [[ "$HHMM" < "$INIZIO" ]] || [[ "$HHMM" > "$FINE" ]] && continue

        TS_SEC=$(time_to_seconds "$TS")

        if [[ "$LINE" == *"tela bloccata"* ]]; then
            RIGHE_FERMI+="$LINE"$'\n'
            if [[ $FERMO_IN_CORSO -eq 0 ]]; then
                FERMO_IN_CORSO=1
                TS_INIZIO_FERMO=$TS_SEC
            fi
        else
            if [[ $FERMO_IN_CORSO -eq 1 ]]; then
                FERMO_IN_CORSO=0
                SEC_FERMO=$((SEC_FERMO + TS_SEC - TS_INIZIO_FERMO))
            fi
        fi
    done < "$FILE_LOG"
    [[ $FERMO_IN_CORSO -eq 1 ]] && SEC_FERMO=$((SEC_FERMO + TS_SEC - TS_INIZIO_FERMO))
done

if [ -n "$RULLO" ]; then
    echo "Il rullo $RULLO è stato fermo per $SEC_FERMO volte il $DATA tra $INIZIO e $FINE"
else
    echo "Le tele sono state ferme per $SEC_FERMO volte il $DATA tra $INIZIO e $FINE"
fi
echo "Dettaglio fermate:"
echo "$RIGHE_FERMI"
