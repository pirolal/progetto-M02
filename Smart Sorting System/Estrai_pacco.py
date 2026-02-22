import sqlite3  # Importa la libreria per interagire con il database SQLite
import sys      # Importa la libreria per leggere gli argomenti passati da riga di comando (es. --filtra)

# Funzione di utilità per stabilire la connessione al database
def connetti():
    return sqlite3.connect('gestione_spedizioni.db')

# Funzione per recuperare la lista completa dei pacchi (usata per il ciclo principale -i)
def estrai_tutti():
    conn = connetti()
    cursor = conn.cursor()
    # Esegue una JOIN tra pacchi e clienti per associare a ogni pacco il nome del proprietario
    cursor.execute("SELECT p.id_pacco, c.nome FROM pacchi p JOIN clienti c ON p.id_cliente = c.id_cliente")
    risultati = cursor.fetchall()
    conn.close()
    # Restituisce una stringa formattata come "ID|Nome ID|Nome" per essere letta facilmente dal Bash
    return " ".join([f"{r[0]}|{r[1]}" for r in risultati])

# Funzione per mostrare tutti i pacchi che sono stati assegnati a un sensore specifico
def filtra_sensore(n):
    conn = connetti()
    cursor = conn.cursor()
    # Seleziona gli ID dei pacchi dove la colonna 'sensore' corrisponde al numero fornito
    cursor.execute("SELECT id_pacco FROM pacchi WHERE sensore = ?", (n,))
    risultati = cursor.fetchall()
    conn.close()
    # Stampa l'elenco dei pacchi trovati per quel sensore
    for r in risultati: 
        print(f"Pacco ID {r[0]}")

# Funzione per rintracciare il percorso di un singolo pacco tramite il suo ID
def cerca_pacco(id_pacco):
    conn = connetti()
    cursor = conn.cursor()
    # Cerca il valore della colonna 'sensore' per un determinato ID pacco
    cursor.execute("SELECT sensore FROM pacchi WHERE id_pacco = ?", (id_pacco,))
    res = cursor.fetchone()
    conn.close()
    # Se il pacco esiste, mostra il sensore assegnato, altrimenti avvisa dell'errore
    if res:
        print(f"Il pacco {id_pacco} è passato dal sensore {res[0]}")
    else:
        print("Pacco non trovato.")

# Punto di ingresso dello script che decide quale funzione eseguire in base agli argomenti ricevuti
if __name__ == "__main__":
    # Caso 1: Nessun argomento aggiuntivo -> Estrae la lista completa per lo smistamento
    if len(sys.argv) == 1:
        print(estrai_tutti())
    
    # Caso 2: Argomento --filtra seguito dal numero del sensore (es. python3 Estrai_pacco.py --filtra 2)
    elif sys.argv[1] == "--filtra":
        filtra_sensore(sys.argv[2])
    
    # Caso 3: Argomento --cerca seguito dall'ID del pacco (es. python3 Estrai_pacco.py --cerca 10)
    elif sys.argv[1] == "--cerca":
        cerca_pacco(sys.argv[2])