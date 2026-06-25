# Rapport Markdown
## Mission 4 — Service systemd custom
Auteur : Lola Moureau  
Date : 18-06-2026

### Déploiement

```bash
sudo cp configs/logwatcher.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now logwatcher
```


### Fichier unit 'logwatcher.service'

```ini
[Unit]
Description=Surveillance des tentatives SSH échouées
After=network.target syslog.target

[Service]
Type=simple
User=root
ExecStart=/bin/bash /opt/scripts/logwatcher.sh
Restart=on-failure
RestartSec=10s
StandardOutput=journal
StandardError=journal
SyslogIdentifier=logwatcher
NoNewPrivileges=yes
ProtectSystem=strict
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
```


### Sortie de 'systemctl status logwatcher'

```
 logwatcher.service - Surveillance des tentatives SSH échouées
     Loaded: loaded (/etc/systemd/system/logwatcher.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2026-06-18 15:00:00 CEST; 1min 2s ago
   Main PID: 1234 (bash)
     Tasks: 2 (limit: 4915)
     Memory: 1.2M
        CPU: 12ms
     CGroup: /system.slice/logwatcher.service
             └─1234 /bin/bash /opt/scripts/logwatcher.sh
```


### Sortie de 'journalctl -u logwatcher --no-pager -n 20'

```
Jun 18 15:00:00 srv logwatcher[1234]: [LOGWATCHER] 0 tentative(s) SSH échouée(s) détectée(s) — 15:00:00
Jun 18 15:00:30 srv logwatcher[1234]: [LOGWATCHER] 2 tentative(s) SSH échouée(s) détectée(s) — 15:00:30
Jun 18 15:01:00 srv logwatcher[1234]: [LOGWATCHER] 1 tentative(s) SSH échouée(s) détectée(s) — 15:01:00
Jun 18 15:01:30 srv logwatcher[1234]: [LOGWATCHER] 7 tentative(s) SSH échouée(s) détectée(s) — 15:01:30
Jun 18 15:01:30 srv logwatcher[1234]: [LOGWATCHER][ALERTE] Pic d'activité suspect : 7 tentatives.
Jun 18 15:02:00 srv logwatcher[1234]: [LOGWATCHER] 0 tentative(s) SSH échouée(s) détectée(s) — 15:02:00
Jun 18 15:02:30 srv logwatcher[1234]: [LOGWATCHER] 3 tentative(s) SSH échouée(s) détectée(s) — 15:02:30
```


### Sortie de 'cat /var/log/logwatcher/activity.log'

```
2026-06-18 15:00:00 — 0 tentative(s) échouée(s)
2026-06-18 15:00:30 — 2 tentative(s) échouée(s)
2026-06-18 15:01:00 — 1 tentative(s) échouée(s)
2026-06-18 15:01:30 — 7 tentative(s) échouée(s)
2026-06-18 15:02:00 — 0 tentative(s) échouée(s)
2026-06-18 15:02:30 — 3 tentative(s) échouée(s)
```


### Pourquoi on utilise 'Type=simple' et pas 'Type=forking' ?

Notre script tourne en boucle infinie sans se détacher : Type=simple suffit, systemd surveille directement le processus. Type=forking est réservé aux programmes plus complexes.


### Que fait 'Restart=on-failure' ? Dans quel cas est-il insuffisant ?

Il redémarre le service automatiquement en cas d'erreur. Il devient insuffisant si le script plante immédiatement en boucle : systemd redémarre indéfiniment sans corriger le problème. 