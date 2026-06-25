#!/bin/bash
# ============================================================
# Script : create_users.sh
# Auteur : Lola Moureau
# Date : 18/06/26
# Desc : équipe de travail partagée
# Usage : sudo ./create_users.sh
# ============================================================
# Vérification root
if [ "$EUID" -ne 0 ]; then
echo "[ERREUR] Ce script doit être lancé en tant que root." >&2
exit 1
fi
# Variables
GROUPE_DEV="dev_team"
GID_DEV=3001

GROUPE_OPS="ops_team"
GID_OPS=3002

# Arborescence
mkdir -p "$PROJECT_DIR"/{src,docs,releases,logs}
echo "[INFO] Dossiers créés."

# Permissions et propriétaires
chown root:"$GROUPE_DEV" "$PROJECT_DIR/src" "$PROJECT_DIR/docs"
chmod 770 "$PROJECT_DIR/src" "$PROJECT_DIR/docs"
echo "[INFO] src/ et docs/ : 770 root:$GROUPE_DEV"

chown root:"$GROUPE_DEV" "$PROJECT_DIR/releases"
chmod 750 "$PROJECT_DIR/releases"
echo "[INFO] releases/ : 750 root:$GROUPE_DEV"

chown root:root "$PROJECT_DIR/logs"
chmod 700 "$PROJECT_DIR/logs"
echo "[INFO] logs/ : 700 root:root"

# Sticky bit + SGID sur src/ et docs/
chmod +t "$PROJECT_DIR/src" "$PROJECT_DIR/docs"
chmod g+s "$PROJECT_DIR/src" "$PROJECT_DIR/docs"
echo "[INFO] Sticky bit et SGID posés sur src/ et docs/."

# ACL : charlie en lecture sur docs/
if ! command -v setfacl &>/dev/null; then
    echo "[ERREUR] setfacl introuvable. Installez acl : apt install acl" >&2
    exit 1
fi
if ! id "charlie" &>/dev/null; then
    echo "[ERREUR] Utilisateur charlie introuvable. Lancez d'abord create_users.sh." >&2
    exit 1
fi
setfacl -m u:charlie:r-x "$PROJECT_DIR/docs"
echo "[INFO] ACL : charlie r-x sur docs/."

# Fichiers de test
touch "$PROJECT_DIR/src/main.c"
touch "$PROJECT_DIR/docs/ARCHITECTURE.md"
touch "$PROJECT_DIR/releases/v1.0.tar.gz"
echo "[INFO] Fichiers de test créés."

# Récapitulatif
echo ""
echo "=== ls -laR $PROJECT_DIR ==="
ls -laR "$PROJECT_DIR"

echo ""
echo "=== getfacl $PROJECT_DIR/docs/ ==="
getfacl "$PROJECT_DIR/docs"