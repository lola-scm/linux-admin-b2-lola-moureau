#!/bin/bash
# ============================================================
# Script : create_users.sh
# Auteur : Prénom NOM
# Date : $(date +%Y-%m-%d)
# Desc : Création automatisée des comptes équipe dev
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

# Création du groupe dev_team s'il n'existe pas
if ! getent group "$GROUPE_DEV" > /dev/null; then
    groupadd "$GROUPE_DEV"
    echo "[INFO] Groupe $GROUPE_DEV créé."
else
    echo "[INFO] Groupe $GROUPE_DEV existe déjà."
fi

# Création du groupe ops_team s'il n'existe pas
if ! getent group "$GROUPE_OPS" > /dev/null; then
    groupadd "$GROUPE_OPS"
    echo "[INFO] Groupe $GROUPE_OPS créé."
else
    echo "[INFO] Groupe $GROUPE_OPS existe déjà."
fi

# Création des utilisateurs

USERNAME="Alice"
if ! id "$USERNAME" &>/dev/null; then
     useradd -m -u 2001 -G "$GROUPE_DEV" -s /bin/bash "$USERNAME"
    echo "$USERNAME" | chpasswd
    echo "[INFO] Utilisateur $USERNAME."
else
    echo "[INFO] Utilisateur $USERNAME existe déjà."
fi

USERNAME="Bob"
if ! id "$USERNAME" &>/dev/null; then
    useradd -m -u 2002 -G "$GROUPE_DEV" -s /bin/bash "$USERNAME"
    echo "$USERNAME" | chpasswd
    echo "[INFO] Utilisateur $USERNAME."
else
    echo "[INFO] Utilisateur $USERNAME existe déjà."
fi  

USERNAME="Charlie"
if ! id "$USERNAME" &>/dev/null; then
    useradd -m -u 2003 -G "$GROUPE_OPS" -s /bin/bash "$USERNAME"

    echo "$USERNAME" | chpasswd
    echo "[INFO] Utilisateur $USERNAME ."
else
    echo "[INFO] Utilisateur $USERNAME existe déjà."
fi  

# Ajout d'alice au groupe ops_team (secondaire)
if id "Alice" &>/dev/null; then
    usermod -aG "$GROUPE_OPS" "Alice"
    echo "[INFO] Utilisateur Alice ajouté au groupe $GROUPE_OPS."
fi  

# Ajout de mots de passe temporaires pour les utilisateurs
PASSWORD_ALICE="Alice123!"
PASSWORD_BOB="Bob123!"
PASSWORD_CHARLIE="Charlie123!"

#Forcer le changement de mot de passe à la première connexion
for USER in Alice Bob Charlie; do
    if id "$USER" &>/dev/null; then
        chage -d 0 "$USER"
        echo "[INFO] Mot de passe temporaire défini pour $USER. Changement obligatoire à la première connexion."
    fi
done    

#créer le répertoire /opt/devproject/ appartenant à root:devteam, avec permissions 770
mkdir -p /opt/devproject
chown root:"$GROUPE_DEV" /opt/devproject
chmod 770 /opt/devproject
echo "[INFO] Répertoire /opt/devproject créé avec les permissions appropriées."

#Afficher un récapitulatif à la fin : liste des utilisateurs créés, leurs groupes, et l'état du répertoire /opt/devproject/.
echo "=== Récapitulatif ==="
for USER in Alice Bob Charlie; do
    if id "$USER" &>/dev/null; then
        GROUPS=$(id -nG "$USER")
        echo "Utilisateur: $USER, Groupes: $GROUPS"
    fi
done
echo "Répertoire /opt/devproject/ :"
ls -ld /opt/devproject  