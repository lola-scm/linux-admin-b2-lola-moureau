# Rapport Markdown
## Mission 5 — Sécurisation SSH & pare-feu
Auteur : Lola Moureau  
Date : 25-06-2026

---

### Exécution du script

```bash
sudo ./scripts/harden_ssh.sh
```

Sortie :

```
[INFO] Sauvegarde créée : /etc/ssh/sshd_config.bak.20260625
[INFO] Directives appliquées.
[INFO] Configuration valide.
[ATTENTION] sshd n'a pas été redémarré.
Vérifiez votre session SSH puis exécutez : sudo systemctl restart sshd
```

---

### Diff `sshd_config.bak` → `sshd_config`

```diff
< #PermitRootLogin prohibit-password
---
> PermitRootLogin no
< #PasswordAuthentication yes
---
> PasswordAuthentication no
< #PubkeyAuthentication yes
---
> PubkeyAuthentication yes
< #MaxAuthTries 6
---
> MaxAuthTries 3
< #LoginGraceTime 2m
---
> LoginGraceTime 20
< #ClientAliveInterval 0
---
> ClientAliveInterval 300
< #ClientAliveCountMax 3
---
> ClientAliveCountMax 2
< #X11Forwarding no
---
> X11Forwarding no
```

---

### Validation de la syntaxe

```bash
sudo sshd -t
```

Sortie :

```
(aucune sortie = configuration valide)
```

---

### Configuration UFW

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw deny from 192.0.2.0/24
sudo ufw enable
```

### Sortie de `sudo ufw status verbose`

```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
80/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
Anywhere                   DENY IN     192.0.2.0/24
```

---

### Test de connexion SSH avec clé

```bash
ssh -i ~/.ssh/id_rsa alice@192.168.1.10
```

Sortie :

```
Welcome to Ubuntu 22.04 LTS
Last login: Wed Jun 25 08:25:00 2026
```

Connexion réussie avec clé, sans mot de passe.

---

### Pourquoi PasswordAuthentication no est plus prioritaire que PermitRootLogin no ?

PermitRootLogin no bloque uniquement le compte root, mais les autres comptes restent attaquables par brute-force.
PasswordAuthentication no supprime l'authentification par mot de passe pour tout le monde. Sans clé SSH, personne ne peut se connecter. C'est une protection bien plus large.

---
