import csv
import random
from datetime import datetime, timedelta

# Configurazione
FILENAME = "presenze3.csv"
BADGES = [1021, 1022, 1023, 1024, 1025, 1026, 1027, 1041, 1042, 1043]
GIORNI_DA_GENERARE = 30  # Puoi modificare questo numero (es. 60, 90, 365)

# Calcolo dinamico: oggi è l'ultimo giorno, poi andiamo indietro di N giorni
DATA_FINE = datetime.now()
DATE_RANGE = [(DATA_FINE - timedelta(days=i)).strftime("%Y-%m-%d") for i in range(GIORNI_DA_GENERARE - 1, -1, -1)]

def genera_orario_ingresso():
    if random.random() < 0.8:
        return "08:00"
    else:
        ritardo = random.randint(1, 45)
        orario = datetime.strptime("08:00", "%H:%M") + timedelta(minutes=ritardo)
        return orario.strftime("%H:%M")

with open(FILENAME, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["BADGE", "STATO", "ORA_IN", "ORA_OUT", "TOT_ORE", "DATA"])
    
    for data in DATE_RANGE:
        # Selezioniamo un numero casuale di dipendenti per quel giorno
        dipendenti_del_giorno = random.sample(BADGES, k=random.randint(5, len(BADGES)))
        
        for badge in dipendenti_del_giorno:
            ora_in = genera_orario_ingresso()
            
            # Se la data è quella di oggi (l'ultima della lista), alcuni sono ancora "IN"
            if data == DATA_FINE.strftime("%Y-%m-%d") and random.random() > 0.7:
                writer.writerow([badge, "IN", ora_in, "", "0.00", data])
            else:
                ore_lavoro = random.randint(4, 9)
                ora_out_dt = datetime.strptime(ora_in, "%H:%M") + timedelta(hours=ore_lavoro)
                ora_out = ora_out_dt.strftime("%H:%M")
                tot_ore = f"{ore_lavoro}.00"
                writer.writerow([badge, "OUT", ora_in, ora_out, tot_ore, data])

print(f"File {FILENAME} generato!")
print(f"Periodo: dal {DATE_RANGE[0]} al {DATE_RANGE[-1]} ({GIORNI_DA_GENERARE} giorni).")
