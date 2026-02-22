#!/bin/bash

LOG_FILE="magazzino.log"

if [ ! -f "$LOG_FILE" ]; then
    echo "Errore: il file $LOG_FILE non esiste. Generalo con Python."
    exit 1
fi

invio_email() {
    echo "=========================================================="
    echo "SISTEMA AUTOMATIZZATO DI NOTIFICA LOGISTICA"
    echo "=========================================================="
    count=0
    
    while IFS='|' read -r id stato mail_a mail_c desc; do
        # In questo caso, inviamo notifiche per i pacchi NON ARRIVATI (Stato 0)
        # come richiesto dai tuoi nuovi dettagli (pacco non arrivato/ritardo)
        if [ "$stato" == "0" ]; then
            ((count++))
            
            echo "Processing Pacco ID: #$id..."
            echo -ne "Connessione al server SMTP... [####      ] 40%\r"
            sleep 0.1
            echo -ne "Criptazione SSL/TLS...        [########  ] 80%\r"
            sleep 0.1
            echo -ne "Invio in corso...             [##########] 100%\r"
            echo -e "\n"

            # --- EMAIL PER L'AZIENDA ---
            echo "----------------------------------------------------------"
            echo "DA: magazzino@logistica.it"
            echo "A: $mail_a"
            echo "OGGETTO: Avviso Mancata Ricezione Pacco #$id"
            echo ""
            echo "Gentile Azienda,"
            echo "Vi informiamo che il pacco in oggetto ($desc) NON è ancora"
            echo "pervenuto presso il nostro centro di smistamento."
            echo "Vi preghiamo di verificare lo stato della spedizione."
            echo "----------------------------------------------------------"

            # --- EMAIL PER IL CLIENTE ---
            echo "DA: customer-service@logistica.it"
            echo "A: $mail_c"
            echo "OGGETTO: Aggiornamento sulla tua consegna #$id"
            echo ""
            echo "Caro Cliente,"
            echo "siamo spiacenti di informarti che la consegna del tuo ordine"
            echo "($desc) subirà un ritardo di circa 2/3 giorni lavorativi"
            echo "causa rallentamenti logistici."
            echo "----------------------------------------------------------"
            echo -e "\n"
            
            sleep 0.3 # Pausa tra un pacco e l'altro per leggibilità
        fi
    done < "$LOG_FILE"
    
    echo "=========================================================="
    echo "PROCEDURA COMPLETATA: $count email inviate correttamente."
    echo "=========================================================="
}

# Funzioni precedenti (stampa e info)
stampa_lista() {
    filtro=$1
    printf "%-5s %-10s %-30s %-30s\n" "ID" "STATO" "EMAIL AZIENDA" "EMAIL CLIENTE"
    echo "---------------------------------------------------------------------------------------"
    while IFS='|' read -r id stato mail_a mail_c desc; do
        if [[ -z "$filtro" || "$stato" == "$filtro" ]]; then
            [ "$stato" == "1" ] && S_TEXT="DENTRO" || S_TEXT="FUORI"
            printf "%-5s %-10s %-30s %-30s\n" "$id" "$S_TEXT" "$mail_a" "$mail_c"
        fi
    done < "$LOG_FILE"
}

mostra_info() {
    printf "%-5s %-15s %-40s\n" "ID" "STATO" "DESCRIZIONE PACCO"
    echo "------------------------------------------------------------"
    while IFS='|' read -r id stato mail_a mail_c desc; do
        [ "$stato" == "1" ] && S_TEXT="DENTRO" || S_TEXT="FUORI"
        printf "%-5s %-15s %-40s\n" "$id" "$S_TEXT" "$desc"
    done < "$LOG_FILE"
}

case "$1" in
    -t) stampa_lista "1" ;;
    -f) stampa_lista "0" ;;
    -i) mostra_info ;;
    -e) invio_email ;;
    *)  stampa_lista "" ;;
esac
