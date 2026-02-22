import random
from datetime import datetime, timedelta

matricole = ["01", "02", "03", "04", "05"]
file_output = "magazzino.txt"
dati_coerenti = {}

# Generiamo dati per gli ultimi 10 giorni
oggi = datetime.now()
for i in range(10):
    data_corrente = (oggi - timedelta(days=i)).strftime("%Y-%m-%d")
    
    for m in matricole:
        # Decidiamo se questa matricola ha lavorato oggi (80% di probabilità)
        if random.random() > 0.2:
            # Generiamo UN SOLO totale per questa persona in questo giorno
            totale_giornaliero = random.randint(100, 500)
            chiave = (m, data_corrente)
            dati_coerenti[chiave] = totale_giornaliero

# Scrittura su file
with open(file_output, mode='w') as f:
    # Mescoliamo i dati per non averli perfettamente in ordine (più realistico)
    items = list(dati_coerenti.items())
    random.shuffle(items)
    
    for (m, data), totale in items:
        riga = f"matricola:{m}-totalepacchi:{totale}-Data:{data}\n"
        f.write(riga)

print(f"File {file_output} generato. Ora ogni matricola ha un solo totale per ogni giorno.")
