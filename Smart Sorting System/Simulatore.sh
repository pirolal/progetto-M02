#!/bin/bash

# Inizio della struttura di controllo 'case' per gestire gli argomenti passati allo script (es. -i, -p, ecc.)
case $1 in
    # Caso '-i': Avvia la sequenza di smistamento automatica
    -i)
        # Esegue lo script Python 'Estrai_pacco.py' e salva la stringa dei pacchi (ID|Nome) nella variabile
        LISTA_DATI=$(python3 Estrai_pacco.py)
        echo "--- Avvio Sequenza Smistamento ---"
        
        # Inizia un ciclo per elaborare ogni pacco contenuto nella lista recuperata
        for VOCE in $LISTA_DATI; do
            # Estrae l'ID del pacco separando la stringa al carattere '|'
            ID=$(echo $VOCE | cut -d'|' -f1)
            # Estrae il Nome del cliente separando la stringa al carattere '|'
            NOME=$(echo $VOCE | cut -d'|' -f2)
            # Genera un numero casuale (1, 2 o 3) chiamando lo script 'Crea_percorso.py'
            PERCORSO=$(python3 Crea_percorso.py)
            
            # Esegue un comando SQL diretto per aggiornare la colonna 'sensore' nel database
            # Questo permette di memorizzare permanentemente dove è stato inviato il pacco
            sqlite3 gestione_spedizioni.db "UPDATE pacchi SET sensore=$PERCORSO WHERE id_pacco=$ID"

            # Messaggi a terminale per simulare l'operazione logistica
            echo "Il pacco con ID $ID (Cliente: $NOME) deve andare tramite il sensore $PERCORSO"
            echo "Sensore $PERCORSO in movimento..."
            # Attende 1 secondo per simulare il tempo fisico di movimento del sensore
            sleep 1
            echo "Pacco arrivato nella tela $PERCORSO"
            echo "-----------------------------------"
            # Piccola pausa prima di passare al pacco successivo
            sleep 0.2
        done
        ;;

    # Caso '-s1', '-s2' o '-s3': Mostra i pacchi smistati in una specifica tela
    -s1|-s2|-s3)
        # Estrae il numero (il terzo carattere della stringa, es. '1' da '-s1')
        NUM_SENS=${1:2} 
        echo "Pacchi passati per il sensore $NUM_SENS:"
        # Chiama 'Estrai_pacco.py' con l'opzione --filtra per interrogare il database
        python3 Estrai_pacco.py --filtra $NUM_SENS
        ;;

    # Caso '-p': Cerca il tragitto di un pacco specifico tramite il suo ID
    -p)
        # Controlla se l'utente ha dimenticato di inserire l'ID dopo il comando
        if [ -z "$2" ]; then
            echo "Inserire l'ID del pacco. Esempio: ./Simulatore.sh -p 10"
        else
            # Chiama 'Estrai_pacco.py' con l'opzione --cerca passandogli l'ID
            python3 Estrai_pacco.py --cerca $2
        fi
        ;;

    # Caso predefinito: Se l'utente scrive comandi errati o nulla, mostra le istruzioni
    *)
        echo "Utilizzo: ./Simulatore.sh [-i | -s1 | -s2 | -s3 | -p ID]"
        ;;
esac # Fine della struttura case