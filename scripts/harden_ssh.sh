#!/bin/bash
# ============================================================
# Script : harden_ssh.sh
# Auteur : Lola Moureau
# Date : 2026-06-25
# Desc : Durcissement de la configuration SSH
# Usage : sudo ./harden_ssh.sh
# ============================================================

if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Ce script doit être lancé en tant que root." >&2
    exit 1
fi

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%Y%m%d)"

# Sauvegarde
cp "$SSHD_CONFIG" "$BACKUP"
echo "[INFO] Sauvegarde créée : $BACKUP"

# Appliquer les modifications
apply() {
    local directive=$1
    local value=$2
    sed -i "s/^#\?${directive}.*/${directive} ${value}/" "$SSHD_CONFIG"
    grep -q "^${directive}" "$SSHD_CONFIG" || echo "${directive} ${value}" >> "$SSHD_CONFIG"
}

apply PermitRootLogin       no
apply PasswordAuthentication no
apply PubkeyAuthentication  yes
apply MaxAuthTries          3
apply LoginGraceTime        20
apply ClientAliveInterval   300
apply ClientAliveCountMax   2
apply X11Forwarding         no

echo "[INFO] Directives appliquées."

# Validation de la syntaxe
if ! sshd -t; then
    echo "[ERREUR] Configuration invalide. Restauration de la sauvegarde..." >&2
    cp "$BACKUP" "$SSHD_CONFIG"
    echo "[INFO] Sauvegarde restaurée."
    exit 1
fi

echo "[INFO] Configuration valide."

# Résumé des modifications
echo ""
echo "=== Diff ancien / nouveau ==="
diff "$BACKUP" "$SSHD_CONFIG"

echo ""
echo "[ATTENTION] sshd n'a pas été redémarré."
echo "Vérifiez votre session SSH puis exécutez : sudo systemctl restart sshd"