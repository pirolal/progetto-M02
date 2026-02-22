#!/bin/bash
echo "Installazione dipendenze..."
npm install express
echo "------------------------------------------------"
echo "Server in avvio su porta 9000"
echo "Per chiudere il server, premi CTRL+C nel terminale."
echo "------------------------------------------------"
node server.js