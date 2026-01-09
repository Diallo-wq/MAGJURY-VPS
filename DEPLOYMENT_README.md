# 🚀 MAGJURY -架构 DE DÉPLOIEMENT VPS

## 📌 RÉSUMÉ DE LA MIGRATION

### Infrastructure Cible
- **Hébergeur** : Hostinger VPS KVM 2
- **OS** : Ubuntu 24.04 LTS
- **Ressources** : 8 GB RAM, 2 vCPU, 100 GB NVMe
- **IP** : 72.62.30.117
- **Domaine** : magjury.org

### Architecture Docker Compose
```
┌─────────────────────────────────────────────────────┐
│                  NGINX (Reverse Proxy)              │
│         SSL/TLS (Let's Encrypt) + HTTP/2            │
│              Ports: 80 (HTTP) → 443 (HTTPS)          │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│            RAILS APP (Puma)                         │
│     Ruby 3.1.4 + Rails 7.0.10                       │
│  2 workers, 5 threads, Port: 3000                   │
└─────────────┬────────────────────┬──────────────────┘
              │                    │
              ▼                    ▼
    ┌─────────────────┐  ┌─────────────────┐
    │  PostgreSQL 15  │  │   Redis 7       │
    │  (Database)     │  │ (Action Cable)  │
    │  Port: 5432     │  │  Port: 6379     │
    └─────────────────┘  └─────────────────┘
              │                    │
              ▼                    ▼
       [Volume: DB]        [Volume: Redis]
```

### Stockage des médias
- **Cloudinary** : Gestion des images/PDFs (externe, pas dans Docker)

---

## 📂 FICHIERS GÉNÉRÉS

### ✅ Livrables créés
1. **Dockerfile** - Image multi-stage optimisée
2. **docker-compose.yml** - Orchestration des 4 services
3. **docker-entrypoint.sh** - Script d'initialisation avec migrations
4. **nginx/magjury.conf** - Configuration Nginx avec SSL
5. **.env.example** - Template des variables d'environnement
6. **deploy.sh** - Script de déploiement automatisé
7. **db-backup.sh** - Gestion des backups PostgreSQL
8. **MIGRATION_GUIDE.md** - Guide complet étape par étape
9. **app/controllers/health_controller.rb** - Endpoint de monitoring
10. **.gitignore** - Exclusions Docker/secrets

---

## ⚡ COMMANDES RAPIDES

### Sur votre machine locale
```bash
# Commiter les changements
git add .
git commit -m "feat: Docker configuration for VPS deployment"
git push origin develop
```

### Sur le VPS (après installation Docker)
```bash
# Cloner le projet
cd /var/www
git clone https://github.com/Katcho555/cash_liquid.git magjury
cd magjury
git checkout develop

# Configurer les secrets
cp .env.example .env
nano .env  # Remplir avec vos vraies valeurs

# Rendre les scripts exécutables
chmod +x deploy.sh db-backup.sh docker-entrypoint.sh

# Premier déploiement
./deploy.sh --first-deploy
```

### Backup et restauration DB
```bash
# Créer un backup
./db-backup.sh --backup

# Restaurer un backup
./db-backup.sh --restore

# Migrer depuis Render
./db-backup.sh --from-render

# Statistiques DB
./db-backup.sh --stats
```

### Déploiement et maintenance
```bash
# Mise à jour de l'app
./deploy.sh --update

# Voir les logs
./deploy.sh --logs

# Statut des services
./deploy.sh --status

# Rollback
./deploy.sh --rollback

# Backup manuel
./deploy.sh --backup
```

---

## 🔐 VARIABLES D'ENVIRONNEMENT REQUISES

Dans le fichier `.env` à créer sur le VPS :
```bash
RAILS_MASTER_KEY=603e6de435474e0ae2b397bc17d58d5f
POSTGRES_DB=magjury_production
POSTGRES_USER=magjury
POSTGRES_PASSWORD=<générer_avec: openssl rand -base64 32>
REDIS_PASSWORD=<générer_avec: openssl rand -base64 32>
CLOUDINARY_URL=cloudinary://585337992323854:hlPOFfZ4BX-Y0_ACDp5B3r3ptMg@dwe47it6l
```

---

## 🔒 CHECKLIST SSL (Let's Encrypt)

1. ✅ Configurer DNS : `magjury.org` → `72.62.30.117`
2. ✅ Vérifier avec : `dig magjury.org +short`
3. ✅ Démarrer l'app temporairement en HTTP
4. ✅ Obtenir les certificats :
   ```bash
   certbot certonly --webroot -w /var/www/certbot \
     -d magjury.org -d www.magjury.org \
     --email votre_email@example.com --agree-tos
   ```
5. ✅ Créer le lien symbolique :
   ```bash
   ln -s /etc/letsencrypt /var/www/magjury/nginx/ssl
   ```
6. ✅ Redémarrer Nginx : `docker compose restart nginx`
7. ✅ Auto-renouvellement (cron) :
   ```bash
   0 3 * * * certbot renew --quiet --post-hook "docker compose -f /var/www/magjury/docker-compose.yml restart nginx"
   ```

---

## 🎯 ORDRE D'EXÉCUTION RECOMMANDÉ

### Phase 1 : Préparation (Local + VPS)
1. Commiter et pusher les fichiers Docker
2. Se connecter au VPS : `ssh root@72.62.30.117`
3. Installer Docker + Docker Compose
4. Configurer le firewall (ufw)
5. Cloner le projet dans `/var/www/magjury`
6. Créer le fichier `.env` avec les secrets

### Phase 2 : Migration de la DB
1. Dumper la DB Render depuis votre machine locale
2. Transférer le dump vers le VPS (scp)
3. Démarrer uniquement PostgreSQL : `docker compose up -d db`
4. Restaurer le dump : `./db-backup.sh --restore`

### Phase 3 : Déploiement initial (sans SSL)
1. Démarrer tous les services : `./deploy.sh --first-deploy`
2. Vérifier l'accès HTTP : `http://72.62.30.117`

### Phase 4 : Configuration DNS + SSL
1. Configurer le DNS : `magjury.org` → `72.62.30.117`
2. Attendre la propagation DNS (15-60 min)
3. Obtenir les certificats Let's Encrypt
4. Activer HTTPS et forcer SSL dans Rails

### Phase 5 : Production
1. Tester HTTPS : `https://magjury.org`
2. Configurer les backups automatiques (cron)
3. Monitorer : `./deploy.sh --status`

---

## 📊 MONITORING

### Health Check
- **Endpoint** : `GET https://magjury.org/up`
- **Réponse OK** :
  ```json
  {
    "status": "ok",
    "timestamp": "2026-01-10T02:00:00Z",
    "version": "7.0.10",
    "environment": "production"
  }
  ```

### Logs Docker
```bash
# Tous les services
docker compose logs -f

# Service spécifique
docker compose logs -f app
docker compose logs -f nginx
docker compose logs -f db
docker compose logs -f redis
```

### Ressources système
```bash
docker stats
free -h
df -h
```

---

## 🆘 SUPPORT & DÉPANNAGE

Consultez le fichier **MIGRATION_GUIDE.md** pour :
- Guide pas à pas détaillé
- Résolution des problèmes courants
- Commandes de diagnostic
- Procédures de rollback

---

## 📞 CONTACTS TECHNIQUES

- **VPS** : Hostinger Support
- **DNS** : Registrar du domaine magjury.org
- **SSL** : Let's Encrypt Community Forum

---

## 🎉 PROCHAINES ÉTAPES

Après le déploiement réussi :
1. ✅ Configurer les backups automatiques
2. ✅ Mettre en place un monitoring (UptimeRobot, etc.)
3. ✅ Documenter le workflow de déploiement pour l'équipe
4. ✅ Tester les procédures de rollback
5. ✅ Optimiser les performances (CDN, caching, etc.)

---

**Version** : 1.0.0  
**Date** : 2026-01-10  
**Environnement** : Production VPS Hostinger
