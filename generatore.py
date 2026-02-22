import sys
import random

def calcola_peso(peso_precedente):
    variazione = random.randint(1, 20)
    # Probabilità 60% aumento, 40% diminuzione
    if random.random() < 0.6:
        nuovo_peso = peso_precedente + variazione
    else:
        nuovo_peso = peso_precedente - variazione
    return max(0, min(500, nuovo_peso))

if __name__ == "__main__":
    try:
        peso_attuale = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    except ValueError:
        peso_attuale = 0
    print(calcola_peso(peso_attuale))
