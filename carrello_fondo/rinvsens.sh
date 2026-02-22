#!/bin/bash
# Specifica l'interprete Bash

FILE_DATI="storico_altezze.txt"
SOGLIA=100

# --- FUNZIONE MOSTRA STORICO ---
mostra_storico() {
    local DATA_INIZIO=$1
    local DATA_FINE=$2
    local CONTEGGIO=0

    if [ ! -f "$FILE_DATI" ]; then
        python3 generaaltezza.py
    fi

    echo "Analisi: $DATA_INIZIO / $DATA_FINE"
    echo "------------------------------------------------"
    
    while read -r r_data r_ora r_altezza; do
        # Logica di confronto date: deve essere compresa tra INIZIO e FINE
        if [[ "$r_data" > "$DATA_INIZIO" || "$r_data" == "$DATA_INIZIO" ]] && \
           [[ "$r_data" < "$DATA_FINE" || "$r_data" == "$DATA_FINE" ]]; then
            
            SUPERATA=$(python3 -c "print($r_altezza > $SOGLIA)")
            
            if [ "$SUPERATA" == "True" ]; then
                echo "$r_data [$r_ora] - $r_altezza cm"
                ((CONTEGGIO++))
            fi
        fi
    done < "$FILE_DATI"

    echo "------------------------------------------------"
    echo "Totale superamenti soglia: $CONTEGGIO"
}

# --- GESTIONE ERRORI E PARAMETRI (getopts) ---
# Se non vengono passati argomenti, lo script parte in modalità LIVE
if [ $# -eq 0 ]; then
    MODALITA="LIVE"
else
    # Analizziamo i flag passati
    case "$1" in
        -d)
            # Controllo: -d deve avere esattamente 1 argomento dopo (la data)
            # Quindi in totale devono esserci 2 argomenti ($1 e $2)
            if [ $# -ne 2 ]; then
                echo "❌ Errore di inserimento!"
                echo "Uso corretto: $0 -d AAAA-MM-GG"
                exit 1
            fi
            mostra_storico "$2" "$2"
            exit 0
            ;;
        -g)
            # Controllo: -g deve avere esattamente 2 argomenti dopo (inizio e fine)
            # Quindi in totale devono esserci 3 argomenti ($1, $2 e $3)
            if [ $# -ne 3 ]; then
                echo "❌ Errore di inserimento!"
                echo "Uso corretto: $0 -g DATA_INIZIO DATA_FINE"
                exit 1
            fi
            mostra_storico "$2" "$3"
            exit 0
            ;;
        *)
            # Se l'utente scrive una "cagata" (es. -pip o -ciao)
            echo "❌ Errore: Flag '$1' non riconosciuto!"
            echo "Possibili flag utilizzabili:"
            echo "  -d [data]           -> Analisi giorno singolo"
            echo "  -g [inizio] [fine]  -> Analisi intervallo date"
            echo "  (nessun flag)       -> Monitoraggio LIVE"
            exit 1
            ;;
    esac
fi

# --- MONITORAGGIO LIVE ---
# Questa parte viene eseguita solo se MODALITA è LIVE (nessun flag inserito)
echo "📡 Monitoraggio area carrello avviato (LIVE)"
ALTEZZA_ATTUALE=10.0

while true; do
    ALTEZZA_ATTUALE=$(python3 generaaltezza.py --live "$ALTEZZA_ATTUALE")
    echo "[$(date +%H:%M:%S)] $ALTEZZA_ATTUALE cm"

    SUPERATA=$(python3 -c "print($ALTEZZA_ATTUALE > $SOGLIA)")

    if [ "$SUPERATA" == "True" ]; then
        echo "------------------------------------------------"
        echo "⚠️  Soglia superata! Svuotare carrello."
        echo "------------------------------------------------"
        sleep 3
        ALTEZZA_ATTUALE=10.0
    fi
    sleep 2
done
