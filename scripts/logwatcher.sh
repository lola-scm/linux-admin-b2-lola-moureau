#!/bin/bash
# ============================================================
# Script : logwatcher.sh
# Auteur : Lola Moureau
# Date : 2026-06-18
# Desc : Surveillance des connexions SSH
# Usage : lancé automatiquement par systemd
# ============================================================

LOG_FILE='/var/log/logwatcher/activity.log'
INTERVAL=30
SEUIL=5

# Créer le répertoire de log si nécessaire
mkdir -p /var/log/logwatcher

LAST_LINE=0

while true; do
    # Compter les tentatives échouées
    TENTATIVES=$(grep -c 'Failed password\|Invalid user' /var/log/auth.log 2>/dev/null || echo 0)
    NOUVELLES=$((TENTATIVES - LAST_LINE))
    LAST_LINE=$TENTATIVES

    HEURE=$(date +%H:%M:%S)

    # Log systemd
    echo "[LOGWATCHER] $NOUVELLES tentative SSH échouée détectée — $HEURE" >&2

    # Alerte si dépassement du seuil
    if [ "$NOUVELLES" -gt "$SEUIL" ]; then
        echo "[LOGWATCHER][ALERTE] Pic d'activité suspect : $NOUVELLES tentatives." >&2
    fi

    # Log fichier rotatif
    echo "$(date '+%Y-%m-%d %H:%M:%S') — $NOUVELLES tentative(s) échouée(s)" >> "$LOG_FILE"

    sleep $INTERVAL
done
