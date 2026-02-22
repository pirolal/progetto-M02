import random  # Importa il modulo per la generazione di scelte casuali
from datetime import datetime  # Importa il modulo per gestire date e orari correnti

def genera_assenti():
    try:
        # Tenta di aprire il file 'corrieri.csv' in modalità lettura ('r')
        with open('corrieri.csv', 'r') as f:
            # Legge tutte le righe, rimuove gli spazi bianchi e ignora le righe vuote
            righe = [r.strip() for r in f.readlines() if r.strip()]
        
        # Considera solo i primi 20 corrieri presenti nel file per la simulazione
        righe = righe[:20]
        
        # Genera un numero casuale di assenti compreso tra 1 e 4
        num_assenti = random.randint(1, 4)
        # Seleziona casualmente i corrieri assenti dalla lista totale senza ripetizioni
        corrieri_assenti = random.sample(righe, num_assenti)
        
        # Crea o sovrascrive il file 'registro_assenti.txt' per il report ufficiale
        with open('registro_assenti.txt', 'w') as f_reg:
            # Scrive l'intestazione del report con la data e l'ora attuale formattata
            f_reg.write(f"REPORT ASSENZE - {datetime.now().strftime('%d/%m/%Y %H:%M')}\n")
            # Aggiunge una riga di separazione estetica
            f_reg.write("-" * 30 + "\n")
            # Cicla attraverso i corrieri selezionati come assenti
            for c in corrieri_assenti:
                # Divide i dati del corriere (separati da virgola nel CSV) in una lista
                d = c.split(',')
                # Scrive i dettagli dell'assente (Nome, Cognome e Telefono) nel registro
                f_reg.write(f"ASSENTE: {d[0]} {d[1]} | Tel: {d[2]}\n")
        
        # Crea un file temporaneo nascosto '.nomi_assenti.tmp' per l'integrazione con Bash
        with open('.nomi_assenti.tmp', 'w') as f_tmp:
            for c in corrieri_assenti:
                # Scrive la riga completa del corriere assente nel file temporaneo
                f_tmp.write(c + "\n")
                
    except FileNotFoundError:
        # Gestisce il caso in cui il file sorgente 'corrieri.csv' non sia presente nella cartella
        print("Errore: corrieri.csv non trovato!")

# Verifica se lo script è eseguito direttamente (non importato come modulo)
if __name__ == "__main__":
    # Avvia la funzione per generare il report delle assenze
    genera_assenti()