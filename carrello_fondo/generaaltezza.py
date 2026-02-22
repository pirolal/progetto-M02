import random
import sys
from datetime import datetime, timedelta

# Funzione per creare il database storico
def genera_database_storico():
    file_output = "storico_altezze.txt"
    data_inizio = datetime(2026, 2, 1) # Inizio Febbraio
    data_oggi = datetime.now()         # Oggi
    delta = data_oggi - data_inizio    # Giorni trascorsi
    
    with open(file_output, "w") as f:
        # Per ogni giorno dal 1/02 a oggi
        for g in range(delta.days + 1):
            data_corrente = data_inizio + timedelta(days=g)
            data_str = data_corrente.strftime("%Y-%m-%d")
            
            # Genera 50 letture distribuite nell'arco della giornata
            for i in range(50):
                # Genera un orario fittizio (es. ogni 20 minuti circa)
                ora_str = (datetime(2026, 1, 1, 8, 0) + timedelta(minutes=i*20)).strftime("%H:%M")
                altezza = round(random.uniform(10, 130), 2)
                # Formato: DATA ORA ALTEZZA
                f.write(f"{data_str} {ora_str} {altezza}\n")

# Funzione per la crescita lenta nel monitoraggio live
def lettura_live(ultima_altezza):
    nuova = float(ultima_altezza) + random.uniform(2, 8)
    return round(nuova, 2)

if _name_ == "_main_":
    if len(sys.argv) > 1 and sys.argv[1] == "--live":
        attuale = sys.argv[2] if len(sys.argv) > 2 else 10.0
        print(lettura_live(attuale))
    else:
        # Genera il file con Data, Ora e Altezza
        genera_database_storico()
