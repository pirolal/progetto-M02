import sqlite3
import random

def crea_database():
    conn = sqlite3.connect('gestione_spedizioni.db')
    cursor = conn.cursor()
    cursor.execute("PRAGMA foreign_keys = ON;")

    # Reset tabelle
    cursor.execute('DROP TABLE IF EXISTS pacchi')
    cursor.execute('DROP TABLE IF EXISTS clienti')
    cursor.execute('DROP TABLE IF EXISTS aziende')

    # Creazione Tabelle
    cursor.execute('''CREATE TABLE aziende (
        id_azienda INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        telefono TEXT)''')

    cursor.execute('''CREATE TABLE clienti (
        id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        cognome TEXT NOT NULL,
        email TEXT UNIQUE,
        id_azienda INTEGER,
        FOREIGN KEY (id_azienda) REFERENCES aziende (id_azienda) ON DELETE CASCADE)''')

    cursor.execute('''CREATE TABLE pacchi (
        id_pacco INTEGER PRIMARY KEY AUTOINCREMENT,
        descrizione TEXT NOT NULL,
        id_cliente INTEGER,
        FOREIGN KEY (id_cliente) REFERENCES clienti (id_cliente) ON DELETE CASCADE)''')

    # --- POPOLAMENTO MASSIVO (50 record per tabella) ---

    # Liste di supporto per generare dati semi-casuali
    nomi_base = ["Tech", "Global", "Logistica", "Speedy", "Smart", "Future", "Green", "Ocean", "Sky", "Nova"]
    suffissi = ["SpA", "Srl", "Group", "Solutions", "Italia"]
    persone_nomi = ["Marco", "sofia", "Alessandro", "Giulia", "Luca", "Emma", "Davide", "Alice", "Roberto", "Elena"]
    persone_cognomi = ["Rossi", "Ferrari", "Esposito", "Bianchi", "Romano", "Colombo", "Ricci", "Marino", "Greco", "Bruno"]
    oggetti = ["Smartphone", "Laptop", "Libro", "Caffettiera", "Zaino", "Monitor", "Cuffie", "Tastiera", "Lampada", "Orologio"]

    # 1. Popolamento Aziende (50)
    for i in range(1, 51):
        nome_az = f"{random.choice(nomi_base)} {random.choice(suffissi)} {i}"
        email_az = f"info@azienda{i}.it"
        tel = f"0{random.randint(10, 99)}-{random.randint(100000, 999999)}"
        cursor.execute("INSERT INTO aziende (nome, email, telefono) VALUES (?, ?, ?)", (nome_az, email_az, tel))

    # 2. Popolamento Clienti (50)
    # Colleghiamo ogni cliente a un'azienda (id da 1 a 50)
    for i in range(1, 51):
        nome = random.choice(persone_nomi)
        cognome = random.choice(persone_cognomi)
        email = f"{nome.lower()}.{cognome.lower()}{i}@example.com"
        cursor.execute("INSERT INTO clienti (nome, cognome, email, id_azienda) VALUES (?, ?, ?, ?)", 
                       (nome, cognome, email, i))

    # 3. Popolamento Pacchi (50)
    # Ogni cliente (id da 1 a 50) riceve un pacco
    for i in range(1, 51):
        desc = f"{random.choice(oggetti)} modello {random.randint(100, 999)}"
        cursor.execute("INSERT INTO pacchi (descrizione, id_cliente) VALUES (?, ?)", (desc, i))

    conn.commit()
    conn.close()
    print("Database creato e popolato con 50 record per tabella!")

if __name__ == "__main__":
    crea_database()
