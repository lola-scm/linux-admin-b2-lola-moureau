# Rapport Markdown
## Mission 3 — Système de fichiers & permissions
Auteur : Lola Moureau  
Date : 18-06-2026

---

### Exécution du script

```bash
sudo ./scripts/setup_project.sh
```

Sortie :

```
[INFO] Dossiers créés.
[INFO] src/ et docs/ : 770 root:devteam
[INFO] releases/ : 750 root:devteam
[INFO] logs/ : 700 root:root
[INFO] Sticky bit et SGID posés sur src/ et docs/.
[INFO] ACL : charlie r-x sur docs/.
[INFO] Fichiers de test créés.
```

---

### Sortie de `ls -laR /srv/devproject/`

```
/srv/devproject/:
total 24
drwxr-xr-x  6 root  root     4096 Jun 18 12:15 .
drwxr-xr-x 10 root  root     4096 Jun 18 12:15 ..
drwxrws--T  2 root  devteam  4096 Jun 18 12:15 docs
drwx------  2 root  root     4096 Jun 18 12:15 logs
drwxr-x---  2 root  devteam  4096 Jun 18 12:15 releases
drwxrws--T  2 root  devteam  4096 Jun 18 12:15 src

/srv/devproject/docs:
total 8
drwxrws--T  2 root  devteam 4096 Jun 18 12:15 .
drwxr-xr-x  6 root  root    4096 Jun 18 12:15 ..
-rw-r--r--  1 root  devteam    0 Jun 18 12:15 ARCHITECTURE.md

/srv/devproject/logs:
total 8
drwx------  2 root  root 4096 Jun 18 12:15 .
drwxr-xr-x  6 root  root 4096 Jun 18 12:15 ..

/srv/devproject/releases:
total 8
drwxr-x---  2 root  devteam 4096 Jun 18 12:15 .
drwxr-xr-x  6 root  root    4096 Jun 18 12:15 ..
-rw-r--r--  1 root  devteam    0 Jun 18 12:15 v1.0.tar.gz

/srv/devproject/src:
total 8
drwxrws--T  2 root  devteam 4096 Jun 18 12:15 .
drwxr-xr-x  6 root  root    4096 Jun 18 12:15 ..
-rw-r--r--  1 root  devteam    0 Jun 18 12:15 main.c
```

`drwxrws--T` : le `s` sur le bit x du groupe indique le SGID actif, le `T` sur le bit x des autres indique le sticky bit actif.

---

### Sortie de `getfacl /srv/devproject/docs/`

```
# file: srv/devproject/docs
# owner: root
# group: devteam
# flags: -st
user::rwx
user:charlie:r-x
group::rwx
mask::rwx
other::---
```

La ligne `user:charlie:r-x` confirme l'accès en lecture de charlie via ACL, sans modification des permissions POSIX.

---

### Test de validation — alice crée un fichier dans `src/`

```bash
su - alice
touch /srv/devproject/src/test_alice.txt
ls -la /srv/devproject/src/
```

Sortie :

```
-rw-r--r-- 1 root  devteam 0 Jun 18 12:15 main.c
-rw-r--r-- 1 alice devteam 0 Jun 18 12:30 test_alice.txt
```

alice peut créer un fichier dans `src/`. Le groupe du fichier est bien **devteam** grâce au bit SGID.

---

### Test de validation — charlie lit un fichier dans `docs/`

```bash
su - charlie
cat /srv/devproject/docs/ARCHITECTURE.md
ls /srv/devproject/docs/
```

Sortie :

```
ARCHITECTURE.md
```

charlie peut lire le contenu de `docs/` grâce à la règle ACL.


```bash
touch /srv/devproject/docs/test_charlie.txt
```

Sortie :

```
touch: cannot touch '/srv/devproject/docs/test_charlie.txt': Permission denied
```

charlie ne peut pas écrire dans `docs/`, uniquement lire.

---

### Pourquoi le bit SGID est-il utile en contexte collaboratif ?

Sans SGID, un fichier créé par alice appartient à son groupe primaire, donc bob ne pourrait pas y accéder même en ayant les droits

Le bit SGID permets à tous les membres d'une équipe d'accéder aux nouveaux fichiers