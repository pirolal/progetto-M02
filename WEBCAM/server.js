const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();
const PORT = 9000;

app.use(express.json());
app.use(express.static('.'));

/**
 * Funzione Potenziata: Crea l'intera struttura Anno -> 12 Mesi -> Tutti i Giorni
 */
function inizializzaArchivioAnnuale() {
    const ora = new Date();
    const anno = ora.getFullYear().toString();
    const nomiMesi = [
        "01-Gennaio", "02-Febbraio", "03-Marzo", "04-Aprile", 
        "05-Maggio", "06-Giugno", "07-Luglio", "08-Agosto", 
        "09-Settembre", "10-Ottobre", "11-Novembre", "12-Dicembre"
    ];

    console.log(`[SISTEMA] Avvio generazione archivio annuale per il ${anno}...`);

    nomiMesi.forEach((meseNome, indiceMese) => {
        // Calcola quanti giorni ha quel mese specifico in quell'anno
        const ultimoGiorno = new Date(ora.getFullYear(), indiceMese + 1, 0).getDate();
        
        for (let giorno = 1; giorno <= ultimoGiorno; giorno++) {
            const giornoStr = giorno.toString().padStart(2, '0');
            // Percorso: Archivio_Sorveglianza / 2026 / 01-Gennaio / Giorno-01
            const directory = path.join(__dirname, 'Archivio_Sorveglianza', anno, meseNome, `Giorno-${giornoStr}`);
            
            if (!fs.existsSync(directory)) {
                fs.mkdirSync(directory, { recursive: true });
            }
        }
    });

    console.log(`[SISTEMA] Archivio ${anno} completato. 12 mesi e 365 giorni pronti.`);
}

// Esegui la creazione totale all'avvio
inizializzaArchivioAnnuale();

/**
 * Funzione per trovare la cartella corretta in cui salvare il log di oggi
 */
function getTodayPath() {
    const ora = new Date();
    const anno = ora.getFullYear().toString();
    const meseCorrente = ora.getMonth();
    const nomiMesi = [
        "01-Gennaio", "02-Febbraio", "03-Marzo", "04-Aprile", 
        "05-Maggio", "06-Giugno", "07-Luglio", "08-Agosto", 
        "09-Settembre", "10-Ottobre", "11-Novembre", "12-Dicembre"
    ];
    const giornoStr = ora.getDate().toString().padStart(2, '0');
    
    return path.join(__dirname, 'Archivio_Sorveglianza', anno, nomiMesi[meseCorrente], `Giorno-${giornoStr}`);
}

app.post('/auto-save', (req, res) => {
    const { cameras, timestamp } = req.body;
    const targetFolder = getTodayPath();
    const logFile = path.join(targetFolder, 'report_accesso.csv');

    let logData = "";
    cameras.forEach(cam => {
        logData += `Telecamera ${cam}, ${timestamp}, STATUS: Online, Salvataggio: OK\n`;
    });

    fs.appendFile(logFile, logData, (err) => {
        if (err) return res.status(500).send("Errore salvataggio");
        res.send("Dati salvati nella cartella del giorno corrispondente");
    });
});

app.get('/get-logs', (req, res) => {
    const targetFolder = getTodayPath();
    const logFile = path.join(targetFolder, 'report_accesso.csv');
    
    if (fs.existsSync(logFile)) {
        res.send(fs.readFileSync(logFile, 'utf8'));
    } else {
        res.send("Nessun log per oggi. Archivio però pronto.");
    }
});

app.listen(PORT, () => {
    console.log(`------------------------------------------------`);
    console.log(`SISTEMA ATTIVO: http://localhost:${PORT}`);
    console.log(`L'intero archivio annuale è stato generato.`);
    console.log(`------------------------------------------------`);
});