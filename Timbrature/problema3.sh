#!/bin/bash

CSV="presenze3.csv"
ORARIO_INGRESSO_PREVISTO="08:00"

CMD="$1"
BADGE_OR_DATE="$2"
DATE_ARG="$3"

NOW=$(date +"%H:%M")
TODAY=$(date +"%Y-%m-%d")

# Funzione per mostrare chi è in servizio (ora è il comportamento di default)
show_active() {
    echo "Dipendenti attualmente in servizio oggi ($TODAY):"
    echo "-------------------------------------------"
    # Cerca chi ha lo stato IN nella data odierna
    ACTIVE_USERS=$(grep ",IN," "$CSV" | grep "$TODAY")
    
    if [ -z "$ACTIVE_USERS" ]; then
        echo "Nessun dipendente in servizio al momento."
    else
        printf "%-8s | %-5s\n" "BADGE" "ENTRATA"
        echo "-------------------"
        echo "$ACTIVE_USERS" | cut -d, -f1,3 | tr ',' '\t'
    fi
}

usage() {
    echo "Uso:"
    echo "  $0                  (Senza argomenti: Chi è in servizio ora)"
    echo "  $0 -io <BADGE>       (Timbra entrata/uscita)"
    echo "  $0 -s  <BADGE>       (Storico badge)"
    echo "  $0 -d  <BADGE> <DATA> (Dettaglio badge in data X)"
    echo "  $0 -date <YYYY-MM-DD> (Tutti i dipendenti in data X)"
    echo "  $0 -r  <BADGE>       (Report ritardi specifico badge)"
    exit 1
}

to_min() {
    local hh=${1%%:*}
    local mm=${1##*:}
    echo $(( 10#$hh * 60 + 10#$mm ))
}

to_decimal() {
    local minuti=$1
    local ore=$(( minuti / 60 ))
    local rest=$(( (minuti % 60) * 100 / 60 ))
    printf "%d.%02d" $ore $rest
}

# Se non viene passato alcun comando, mostra i dipendenti attivi ed esce
if [[ -z "$CMD" ]]; then
    show_active
    exit 0
fi

# ===================== REPORT RITARDI (-r) =====================
if [ "$CMD" = "-r" ]; then
    BADGE=$BADGE_OR_DATE
    [[ -z "$BADGE" ]] && usage
    
    echo "Analisi Ritardi per Badge: $BADGE"
    echo "-------------------------------------------"
    
    # Leggiamo correttamente tutte le colonne: BADGE,STATO,ORA_IN,ORA_OUT,TOT_ORE,DATA
    grep "^$BADGE," "$CSV" | while IFS=, read -r b s o_in o_out tot d; do
        m_p=$(to_min "$ORARIO_INGRESSO_PREVISTO")
        m_e=$(to_min "$o_in")
        
        # Pulizia della data (rimuove eventuali spazi o ritorni a capo)
        d_clean=$(echo $d | tr -d '\r')
        
        if [ "$m_e" -gt "$m_p" ]; then
            ritardo=$((m_e - m_p))
            echo "Giorno: $d_clean | Entrata: $o_in | ⚠️ RITARDO: $ritardo min"
        else
            echo "Giorno: $d_clean | Entrata: $o_in | ✅ PUNTUALE"
        fi
    done
    exit 0
fi

# ===================== TIMBRATURA (-io) =====================
if [ "$CMD" = "-io" ]; then
    BADGE=$BADGE_OR_DATE
    [[ ! "$BADGE" =~ ^[0-9]+$ ]] && { echo "❌ Badge non valido"; exit 1; }
    
    LINE=$(grep "^$BADGE," "$CSV" | grep "$TODAY")

    if [ -z "$LINE" ]; then
        min_p=$(to_min "$ORARIO_INGRESSO_PREVISTO")
        min_e=$(to_min "$NOW")
        [[ "$min_e" -gt "$min_p" ]] && echo "⚠️ Ritardo: $((min_e - min_p)) min."
        echo "$BADGE,IN,$NOW,,0.00,$TODAY" >> "$CSV"
        echo "🟢 Badge $BADGE → IN ($NOW)"
    else
        STATO=$(echo "$LINE" | cut -d, -f2)
        ORA_IN=$(echo "$LINE" | cut -d, -f3)
        if [ "$STATO" = "IN" ]; then
            diff=$(( $(to_min "$NOW") - $(to_min "$ORA_IN") ))
            NEW_TOT=$(to_decimal $diff)
            sed -i "/^$BADGE,.*,$TODAY/c\\$BADGE,OUT,$ORA_IN,$NOW,$NEW_TOT,$TODAY" "$CSV"
            echo "🔴 Badge $BADGE → OUT ($NOW) - Ore: $NEW_TOT"
        else
            sed -i "/^$BADGE,.*,$TODAY/c\\$BADGE,IN,$NOW,,0.00,$TODAY" "$CSV"
            echo "🟢 Badge $BADGE → RIENTRO"
        fi
    fi
    exit 0
fi

# ===================== CONTROLLO DATA COLLETTIVO (-date) =====================
if [ "$CMD" = "-date" ]; then
    TARGET_DATE=$BADGE_OR_DATE
    [[ -z "$TARGET_DATE" ]] && usage
    
    echo "Report dipendenti per il giorno: $TARGET_DATE"
    echo "--------------------------------------------------------------"
    printf "%-8s | %-5s | %-5s | %-6s | %-s\n" "BADGE" "IN" "OUT" "ORE" "STATO RITARDO"
    echo "--------------------------------------------------------------"

    grep "$TARGET_DATE" "$CSV" | while IFS=, read -r b s o_in o_out tot d; do
        m_p=$(to_min "$ORARIO_INGRESSO_PREVISTO")
        m_e=$(to_min "$o_in")
        
        status="OK"
        [[ "$m_e" -gt "$m_p" ]] && status="Ritardo ($((m_e - m_p)) min)"
        
        printf "%-8s | %-5s | %-5s | %-6s | %s\n" "$b" "$o_in" "${o_out:-"--:--"}" "$tot" "$status"
    done
    exit 0
fi

# ===================== STORICO INDIVIDUALE (-s) =====================
if [ "$CMD" = "-s" ]; then
    BADGE=$BADGE_OR_DATE
    echo "Storico Badge $BADGE"
    grep "^$BADGE," "$CSV" | sort -t, -k6 | tr ',' '\t'
    exit 0
fi

# ===================== DETTAGLIO SINGOLO (-d) =====================
if [ "$CMD" = "-d" ]; then
    BADGE=$BADGE_OR_DATE
    grep "^$BADGE," "$CSV" | grep "$DATE_ARG" | tr ',' '\t'
    exit 0
fi

# Se viene inserito un comando inesistente
usage
