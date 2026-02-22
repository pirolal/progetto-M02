import random
from datetime import datetime, timedelta

# --- CONFIG ---
DATA_INIZIO = datetime(2025, 1, 1)
DATA_FINE = datetime(2027, 12, 31)
FILE_OUTPUT = "gestione_tir.txt"

PACCHI_MIN = 50
PACCHI_MAX = 500
TIR_MIN_GIORNO = 1
TIR_MAX_GIORNO = 8

def genera_targa():
    lettere = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return (
        random.choice(lettere)
        + random.choice(lettere)
        + str(random.randint(100, 999))
        + random.choice(lettere)
        + random.choice(lettere)
    )

data_corrente = DATA_INIZIO

with open(FILE_OUTPUT, "w") as file:
    while data_corrente <= DATA_FINE:
        # Decidiamo quanti GRUPPI di arrivi ci sono oggi
        # Se numero_tir è 8, potrebbero esserci 8 arrivi singoli o meno gruppi più numerosi
        tir_rimanenti = random.randint(TIR_MIN_GIORNO, TIR_MAX_GIORNO)

        while tir_rimanenti > 0:
            # Generiamo un orario per questo gruppo
            ora = random.randint(0, 23)
            minuto = random.randint(0, 59)
            orario_str = f"{ora:02d}:{minuto:02d}"
            
            # Decidiamo quanti TIR arrivano in questo preciso minuto (da 1 a 3)
            # Ma non possiamo superare i tir_rimanenti per oggi
            simultanei = random.randint(1, 3)
            if simultanei > tir_rimanenti:
                simultanei = tir_rimanenti
            
            for _ in range(simultanei):
                targa = genera_targa()
                pacchi = random.randint(PACCHI_MIN, PACCHI_MAX)
                
                riga = f"{targa}-{pacchi}-{data_corrente.strftime('%Y-%m-%d')} {orario_str}\n"
                file.write(riga)
                
            tir_rimanenti -= simultanei

        data_corrente += timedelta(days=1)

print(f"✅ File {FILE_OUTPUT} generato con arrivi singoli e multipli.")
