#!/bin/bash

# --- DEFINIZIONE COLORI ---
# Vengono definite variabili per rendere l'output del terminale più leggibile
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color (resetta il colore al predefinito)

# 1. INIZIALIZZAZIONE
# Esegue lo script Python che sceglie casualmente i corrieri assenti e crea i file .tmp
python3 generatore_assenti.py

echo -e "\n${YELLOW}=== APPELLO GIORNALIERO (TOP 20 STAZIONI) ===${NC}"
echo "------------------------------------------------"

# Crea una copia di lavoro del file corrieri per modificarla senza rovinare l'originale
cp corrieri.csv .organico_finale.tmp

# 2. VISUALIZZAZIONE TABELLONE INIZIALE (Solo i primi 20 corrieri in lista)
# Legge le prime 20 righe del CSV originale per fare l'appello
head -n 20 corrieri.csv | while IFS=',' read -r nome cognome tel esp
do
    # Controlla se il corriere corrente è presente nel file degli assenti (.nomi_assenti.tmp)
    if grep -q "$nome,$cognome" .nomi_assenti.tmp; then
        # Se trovato, lo stampa in rosso come ASSENTE
        echo -e "STAZIONE: $nome $cognome \t STATUS: ${RED}[ASSENTE]${NC}"
    else
        # Altrimenti lo stampa in verde come PRESENTE
        echo -e "STAZIONE: $nome $cognome \t STATUS: ${GREEN}[PRESENTE]${NC}"
    fi
done

echo "------------------------------------------------"
echo -e "${BLUE}>>> RILEVATE ASSENZE NEI 20 SLOT. AVVIO RICERCA...${NC}"
sleep 1 # Pausa drammatica per simulare il tempo di elaborazione

# 3. PROCEDURA DI SOSTITUZIONE
# Legge il file degli assenti riga per riga per trovare un sostituto per ognuno
while IFS=',' read -r a_nome a_cognome a_tel a_esp
do
    echo -e "\n${YELLOW}SOSTITUZIONE PER: $a_nome $a_cognome${NC}"
    
    RISPOSTA="NO"
    # Ciclo finché non viene trovato un sostituto che accetta l'incarico
    while [ "$RISPOSTA" == "NO" ]
    do
        # Pesca un sostituto casuale (shuf) che non sia tra gli assenti (grep -vFf)
        SOSTITUTO=$(grep -vFf .nomi_assenti.tmp corrieri.csv | shuf -n 1)
        s_nome=$(echo $SOSTITUTO | cut -d',' -f1)
        s_cognome=$(echo $SOSTITUTO | cut -d',' -f2)
        s_tel=$(echo $SOSTITUTO | cut -d',' -f3)

        echo -ne "Chiamata a $s_nome $s_cognome ($s_tel)... "
        sleep 0.8 # Simula il tempo della telefonata
        
        # Genera un numero casuale da 1 a 10 per simulare la probabilità di risposta
        CHANCE=$(( ( RANDOM % 10 )  + 1 ))
        
        # Se il numero è 7 o inferiore (70% di probabilità), il sostituto accetta
        if [ $CHANCE -le 7 ]; then
            echo -e "${GREEN}ACCETTATO${NC}"
            # Usa 'sed' per sostituire il nome dell'assente con quello del sostituto nel file temporaneo
            sed -i "s/$a_nome,$a_cognome/$s_nome,$s_cognome/g" .organico_finale.tmp
            RISPOSTA="SI" # Esce dal ciclo per questo assente
        else
            # 30% di probabilità che il sostituto rifiuti
            echo -e "${RED}RIFIUTATO${NC}"
            sleep 0.4
        fi
    done
done < .nomi_assenti.tmp # Fine lettura file assenti

# 4. RIEPILOGO FINALE DEI 20 CORRIERI OPERATIVI
echo -e "\n${BLUE}       ORGANICO DEFINITIVO OPERATIVO ORA        ${NC}"

count=1
# Legge le prime 20 righe del file aggiornato con i sostituti
head -n 20 .organico_finale.tmp | while IFS=',' read -r nome cognome tel esp
do
    # Stampa la lista finale numerata e ben incolonnata
    printf "${NC}%2d) STAZIONE: %-20s STATUS: ${GREEN}[ATTIVO]${NC}\n" "$count" "$nome $cognome"
    ((count++))
done

echo -e "------------------------------------------------"
echo -e "${GREEN}OPERAZIONE COMPLETATA: 20/20 SLOT COPERTI.${NC}\n"

# Pulizia dei file temporanei creati durante l'esecuzione per lasciare la cartella ordinata
rm .nomi_assenti.tmp
rm .organico_finale.tmp