import sqlite3
import random

def genera_log_magazzino():
    conn = sqlite3.connect('gestione_spedizioni.db')
    cursor = conn.cursor()
    
    # MODIFICA: Aggiunta p.descrizione nella SELECT
    query = '''
    SELECT p.id_pacco, p.descrizione, a.email, c.email
    FROM pacchi p
    JOIN clienti c ON p.id_cliente = c.id_cliente
    JOIN aziende a ON c.id_azienda = a.id_azienda
    '''
    cursor.execute(query)
    tutti_i_pacchi = cursor.fetchall()
    
    id_arrivati = random.sample(range(1, 51), k=25) 

    with open('magazzino.log', 'w') as f:
        for p in tutti_i_pacchi:
            id_p, desc, mail_a, mail_c = p
            stato = "1" if id_p in id_arrivati else "0"
            # MODIFICA: Scriviamo anche la descrizione nel log
            f.write(f"{id_p}|{stato}|{mail_a}|{mail_c}|{desc}\n")
            
    conn.close()
    print("✅ Log 'magazzino.log' generato con descrizioni.")

if __name__ == "__main__":
    genera_log_magazzino()
