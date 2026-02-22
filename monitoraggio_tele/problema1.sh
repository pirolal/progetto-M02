#!/bin/bash

NUM_RULLI=3  # adesso 3 rulli
PIDS=()

cleanup() {
    echo ""
    echo "⛔ Arresto monitoraggio..."
    for PID in "${PIDS[@]}"; do
        kill "$PID" 2>/dev/null
    done
    wait
    echo "✅ Tutti i rulli fermati"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Lancia i rulli in background
for ((RULLO=1; RULLO<=NUM_RULLI; RULLO++)); do
    ./problema1.2.sh "$RULLO" &
    PIDS+=($!)
done

wait
