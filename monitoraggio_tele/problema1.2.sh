#!/bin/bash

SOGLIA_LED=300
SOGLIA_STOP=500

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="${BASE_DIR}/log_peso"
mkdir -p "$LOG_DIR"

RULLO=$1
PESO_ATTUALE=0

interrupted=false
trap 'interrupted=true' SIGINT SIGTERM

echo "Avviato monitoraggio rullo $RULLO"

while true; do
    $interrupted && exit 0

    ORA_ATTUALE=$(date +%H%M)
    DATA=$(date +%Y-%m-%d)
    ORA_LOG=$(date +%H:%M:%S)  # solo secondi

    LOG_FILE="${LOG_DIR}/log_${DATA}_tela${RULLO}.log"
    [ ! -f "$LOG_FILE" ] && echo "ORA-PESO-LED" > "$LOG_FILE"

    if [ "$ORA_ATTUALE" -ge 0800 ] && [ "$ORA_ATTUALE" -lt 2200 ]; then

        # genera il peso una volta per ciclo
        PESO_ATTUALE=$(python3 generatore.py "$PESO_ATTUALE")

        if [ "$PESO_ATTUALE" -eq "$SOGLIA_STOP" ]; then
            echo "$ORA_LOG - tela bloccata" >> "$LOG_FILE"
            
        else
            LED=0
            [ "$PESO_ATTUALE" -ge "$SOGLIA_LED" ] && LED=1
            echo "${ORA_LOG}-${PESO_ATTUALE}-${LED}" >> "$LOG_FILE"
        fi

        # attende 1 secondo prima della prossima lettura
        sleep 1
    else
        sleep 60
    fi
done
