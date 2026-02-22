import sqlite3
import os

def crea_database():
    # Rimuove il vecchio DB se esiste 
    if os.path.exists('gestione_spedizioni.db'):
        os.remove('gestione_spedizioni.db')

    conn = sqlite3.connect('gestione_spedizioni.db')
    cursor = conn.cursor()
    cursor.execute("PRAGMA foreign_keys = ON;") # Attiva vincoli chiavi esterne 

    # Creazione tabelle 
    cursor.execute('CREATE TABLE aziende (id_azienda INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, email TEXT, telefono TEXT)')
    cursor.execute('CREATE TABLE clienti (id_cliente INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, cognome TEXT, email TEXT, id_azienda INTEGER, FOREIGN KEY (id_azienda) REFERENCES aziende (id_azienda))')
    cursor.execute('CREATE TABLE pacchi (id_pacco INTEGER PRIMARY KEY AUTOINCREMENT, descrizione TEXT, id_cliente INTEGER, sensore INTEGER DEFAULT 0, FOREIGN KEY (id_cliente) REFERENCES clienti (id_cliente))')

    # Dati iniziali 
    cursor.execute("INSERT INTO aziende (nome, email, telefono) VALUES ('Amazon Italia', 'contact@amazon.it', '02-123')")
    cursor.execute("INSERT INTO clienti (nome, cognome, email, id_azienda) VALUES ('Luca', 'Bianchi', 'luca@email.it', 1)")
    
    pacchi = [('Pacco Elettronica ' + str(i), 1) for i in range(1, 51)]
    cursor.executemany("INSERT INTO pacchi (descrizione, id_cliente) VALUES (?, ?)", pacchi)

    conn.commit()
    conn.close()
    print("Database creato e resettato!")

if __name__ == "__main__":
    crea_database()