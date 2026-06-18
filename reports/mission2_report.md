# Rapport Markdown

## Mission 2 — Gestion des utilisateurs
Auteur : Lola Moureau 
Date : 18-06-2026
### Exécution du script
```bash
sudo ./scripts/create_users.sh
```
Sortie :
```
[INFO] Groupe dev_team créé.
[INFO] Groupe ops_team créé.
[INFO] Utilisateur Alice.
[INFO] Utilisateur Bob.
[INFO] Utilisateur Charlie .
[INFO] Répertoire /opt/devproject créé avec les permissions appropriées.
=== Récapitulatif ===
Répertoire /opt/devproject/ :
Utilisateur: Alice, Groupes: Alice dev_team ops_team
Utilisateur: Bob, Groupes: Bob dev_team
Utilisateur: Charlie, Groupes: Charlie ops_team
Répertoire /opt/devproject/ :
drwxrwx--- 2 root dev_team 4096 Jun 18 10:20 /opt/devproject

```
### Vérification des comptes
```bash
id alice
```
uid=2001(Alice) gid=3001(dev_team) groups=3001(dev_team),3002(ops_team)
```
id bob
```
uid=2002(Bob) gid=3001(dev_team) groups=3001(dev_team)
```
id charlie
```
uid=2003(Charlie) gid=3002(ops_team) groups=3002(ops_team)
```

### Vérification des groupes 

```bash
cat /etc/group | grep -E 'dev_team|ops_team'
```
dev_team:x:3001:Alice,Bob
ops_team:x:3002:Charlie,Alice

###Vérification du dossier 

```bash 
ls -ld /opt/devproject/
````
drwxrwx--- 2 root dev_team 4096 Jun 18 10:20 /opt/devproject/

### Script lancé 2 fois ?

Si le script est lancé 2 fois, il n'y a pas d'erreur, car le code vérifie d'abord l'existence des utilisateurs et roupes avant l'exécution, 
cette ligne s'affichera en cas de doublon : "[INFO] Groupe $GROUPE_DEV existe déjà." ou "[INFO] Utilisateur $USERNAME existe déjà."
