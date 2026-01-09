# 🚀 GUIDE DE MIGRATION MAGJURY
## De Render vers VPS Hostinger KVM 2

---

## 📋 TABLE DES MATIÈRES
1. [Prérequis](#prérequis)
2. [Préparation du VPS](#préparation-du-vps)
3. [Installation des dépendances](#installation-des-dépendances)
4. [Configuration du projet](#configuration-du-projet)
5. [Migration de la base de données](#migration-de-la-base-de-données)
6. [Configuration SSL avec Let's Encrypt](#configuration-ssl)
7. [Déploiement et tests](#déploiement)
8. [Monitoring et maintenance](#monitoring)
9. [Dépannage](#dépannage)

---

## ✅ PRÉREQUIS

### Informations à récupérer sur Render
- [ ] `RAILS_MASTER_KEY` (récupérée : `603e6de435474e0ae2b397bc17d58d5f`)
- [ ] URL de connexion PostgreSQL (dans les variables d'environnement)
- [ ] Secrets Cloudinary (cloud_name, api_key, api_secret)

### Accès VPS
- **IP** : `72.62.30.117`
- **OS** : Ubuntu 24.04 LTS
- **Accès** : SSH root (`ssh root@72.62.30.117`)
- **Ressources** : 8 GB RAM, 2 vCPU, 100 GB NVMe

### Domaine
- **Domaine** : `magjury.org`
- **DNS** : À configurer avant Let's Encrypt (Enregistrement A → `72.62.30.117`)

---

## 🔧 ÉTAPE 1 : PRÉPARATION DU VPS

### 1.1 Connexion SSH
```bash
ssh root@72.62.30.117
```

### 1.2 Mise à jour du système
```bash
apt update && apt upgrade -y
```

### 1.3 Installation des outils de base
```bash
apt install -y curl git wget vim ufw fail2ban
```

### 1.4 Configuration du firewall
```bash
# Autoriser SSH, HTTP, HTTPS
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
ufw status
```

### 1.5 Sécurisation SSH (optionnel mais recommandé)
```bash
# Créer un utilisateur non-root (optionnel)
adduser deploy
usermod -aG sudo deploy

# Désactiver le login root SSH (après avoir testé l'utilisateur deploy)
# sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
# systemctl restart ssh
```

---

## 🐳 ÉTAPE 2 : INSTALLATION DES DÉPENDANCES

### 2.1 Installation de Docker
```bash
# Installation de Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Vérification
docker --version
```

### 2.2 Installation de Docker Compose
```bash
# Installation de Docker Compose Plugin
apt install -y docker-compose-plugin

# OU installation standalone (si plugin non dispo)
curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Vérification
docker compose version
```

### 2.3 Installation de Certbot (Let's Encrypt)
```bash
apt install -y certbot python3-certbot-nginx
certbot --version
```

---

## 📦 ÉTAPE 3 : CONFIGURATION DU PROJET

### 3.1 Création de la structure des répertoires
```bash
mkdir -p /var/www/magjury
cd /var/www/magjury
```

### 3.2 Clonage du projet
```bash
# Cloner depuis votre repository
git clone https://github.com/Katcho555/cash_liquid.git .
git checkout develop
```

### 3.3 Création du fichier .env
```bash
# Copier le template
cp .env.example .env

# Éditer avec vos vraies valeurs
nano .env
```

**Contenu du fichier `.env` :**
```bash
# RAILS
RAILS_MASTER_KEY=603e6de435474e0ae2b397bc17d58d5f

# POSTGRESQL
POSTGRES_DB=magjury_production
POSTGRES_USER=magjury
POSTGRES_PASSWORD=VOTRE_MOT_DE_PASSE_SECURISE  # ⚠️ Générez-en un fort !

# REDIS
REDIS_PASSWORD=VOTRE_MOT_DE_PASSE_REDIS  # ⚠️ Générez-en un fort !

# CLOUDINARY
CLOUDINARY_URL=cloudinary://585337992323854:hlPOFfZ4BX-Y0_ACDp5B3r3ptMg@dwe47it6l
```

**💡 Générer des mots de passe sécurisés :**
```bash
# Générer un mot de passe PostgreSQL
openssl rand -base64 32

# Générer un mot de passe Redis
openssl rand -base64 32
```

### 3.4 Création des répertoires nécessaires
```bash
mkdir -p backups log nginx/ssl storage
chmod +x deploy.sh docker-entrypoint.sh
```

---

## 💾 ÉTAPE 4 : MIGRATION DE LA BASE DE DONNÉES

### 4.1 Dump de la base de données depuis Render
**Sur votre machine locale :**

```bash
# Récupérer l'URL PostgreSQL depuis Render
# Format: postgresql://user:password@host:port/database

# Créer le dump
pg_dump -Fc --no-acl --no-owner \
  -h <RENDER_HOST> \
  -U <RENDER_USER> \
  -d <RENDER_DB> \
  > magjury_render_backup.dump

# Ou utiliser l'URL complète
pg_dump -Fc --no-acl --no-owner \
  "postgresql://user:password@host:port/database" \
  > magjury_render_backup.dump
```

### 4.2 Transfert du dump vers le VPS
```bash
# Depuis votre machine locale
scp magjury_render_backup.dump root@72.62.30.117:/var/www/magjury/backups/
```

### 4.3 Restauration sur le VPS
**Sur le VPS :**

```bash
cd /var/www/magjury

# Démarrer UNIQUEMENT la base de données PostgreSQL
docker compose up -d db

# Attendre que PostgreSQL soit prêt (10-15 secondes)
sleep 15

# Restaurer le dump
cat backups/magjury_render_backup.dump | docker exec -i magjury_db \
  pg_restore --no-acl --no-owner -U magjury -d magjury_production

# Vérifier la restauration
docker exec -it magjury_db psql -U magjury -d magjury_production -c "\dt"
```

**⚠️ Si erreur "database does not exist" :**
```bash
# Créer manuellement la base
docker exec -it magjury_db psql -U magjury -c "CREATE DATABASE magjury_production;"

# Puis relancer la restauration
```

---

## 🔐 ÉTAPE 5 : CONFIGURATION SSL AVEC LET'S ENCRYPT

### 5.1 Configuration DNS (À FAIRE AVANT CETTE ÉTAPE)
Vérifier que `magjury.org` pointe vers `72.62.30.117` :
```bash
dig magjury.org +short
# Doit retourner : 72.62.30.117
```

### 5.2 Démarrage temporaire en HTTP (pour validation Let's Encrypt)
**Modifier temporairement `nginx/magjury.conf` :**
```bash
nano nginx/magjury.conf
```

**Commenter les lignes SSL (lignes 15-23 et le bloc server HTTPS) et garder uniquement :**
```nginx
server {
    listen 80;
    server_name magjury.org www.magjury.org;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        allow all;
    }

    location / {
        proxy_pass http://app:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 5.3 Démarrage de l'application (sans SSL)
```bash
cd /var/www/magjury
docker compose up -d
```

Tester l'accès : `http://magjury.org`

### 5.4 Obtention des certificats Let's Encrypt
```bash
# Créer le dossier pour les certificats
mkdir -p /var/www/certbot

# Obtenir les certificats
certbot certonly --webroot \
  -w /var/www/certbot \
  -d magjury.org \
  -d www.magjury.org \
  --email votre_email@example.com \
  --agree-tos \
  --no-eff-email
```

### 5.5 Montage des certificats dans Docker
```bash
# Créer un lien symbolique pour Nginx
ln -s /etc/letsencrypt /var/www/magjury/nginx/ssl
```

### 5.6 Restauration de la configuration Nginx complète
```bash
# Restaurer la config Nginx complète (avec HTTPS)
# Le fichier nginx/magjury.conf est déjà configuré correctement

# Redémarrer Nginx
docker compose restart nginx
```

### 5.7 Vérification SSL
```bash
# Tester HTTPS
curl -I https://magjury.org

# Tester la redirection HTTP → HTTPS
curl -I http://magjury.org
```

### 5.8 Auto-renouvellement des certificats
```bash
# Tester le renouvellement
certbot renew --dry-run

# Configurer le cron pour renouvellement automatique
crontab -e

# Ajouter cette ligne (renouvellement quotidien à 3h du matin)
0 3 * * * certbot renew --quiet --post-hook "docker compose -f /var/www/magjury/docker-compose.yml restart nginx"
```

---

## 🚀 ÉTAPE 6 : DÉPLOIEMENT COMPLET

### 6.1 Activer force_ssl dans Rails
```bash
nano config/environments/production.rb

# Décommenter la ligne 49 :
config.force_ssl = true
```

### 6.2 Commit et rebuild
```bash
git add config/environments/production.rb
git commit -m "Enable force_ssl for production"
git push origin develop

# Sur le VPS, rebuild
cd /var/www/magjury
./deploy.sh --update
```

### 6.3 Vérification complète
```bash
# Statut des services
./deploy.sh --status

# Logs en temps réel
./deploy.sh --logs

# Test de l'application
curl -I https://magjury.org
```

---

## 📊 ÉTAPE 7 : MONITORING ET MAINTENANCE

### 7.1 Commandes utiles
```bash
# Statut des conteneurs
docker compose ps

# Logs d'un service spécifique
docker compose logs -f app
docker compose logs -f nginx
docker compose logs -f db

# Accès au shell d'un conteneur
docker exec -it magjury_app bash
docker exec -it magjury_db psql -U magjury

# Consommation ressources
docker stats

# Espace disque
df -h
docker system df
```

### 7.2 Backups automatiques
```bash
# Créer un backup manuel
./deploy.sh --backup

# Configurer des backups automatiques quotidiens
crontab -e

# Ajouter (backup tous les jours à 2h du matin)
0 2 * * * cd /var/www/magjury && ./deploy.sh --backup
```

### 7.3 Mise à jour de l'application
```bash
cd /var/www/magjury
git pull origin develop
./deploy.sh --update
```

### 7.4 Rollback en cas de problème
```bash
./deploy.sh --rollback
```

---

## 🔥 ÉTAPE 8 : OPTIMISATIONS POST-DÉPLOIEMENT

### 8.1 Configuration de Fail2ban (protection SSH)
```bash
systemctl enable fail2ban
systemctl start fail2ban
fail2ban-client status sshd
```

### 8.2 Nettoyage Docker régulier
```bash
# Ajouter dans crontab (toutes les semaines)
0 4 * * 0 docker system prune -af --volumes
```

### 8.3 Monitoring avec Uptime (optionnel)
- Services comme UptimeRobot (gratuit)
- Configurer un endpoint `/up` dans Rails pour health check

---

## ⚠️ DÉPANNAGE

### Problème : "Database connection failed"
```bash
# Vérifier que PostgreSQL est lancé
docker compose ps db

# Vérifier les logs
docker compose logs db

# Tester la connexion
docker exec -it magjury_db psql -U magjury -d magjury_production
```

### Problème : "Redis connection refused"
```bash
# Vérifier Redis
docker compose logs redis

# Tester Redis
docker exec -it magjury_redis redis-cli -a VOTRE_REDIS_PASSWORD ping
```

### Problème : "Nginx 502 Bad Gateway"
```bash
# Vérifier que l'app Rails est bien démarrée
docker compose logs app

# Vérifier les health checks
docker compose ps

# Redémarrer l'app
docker compose restart app
```

### Problème : "Assets not found"
```bash
# Rebuilder les assets
docker compose exec app bundle exec rails assets:precompile
docker compose restart app
```

### Problème : Certificats SSL expirés
```bash
# Forcer le renouvellement
certbot renew --force-renewal
docker compose restart nginx
```

---

## 📝 CHECKLIST FINALE

- [ ] VPS accessible en SSH
- [ ] Docker et Docker Compose installés
- [ ] Firewall configuré (ports 22, 80, 443)
- [ ] Projet cloné dans `/var/www/magjury`
- [ ] Fichier `.env` configuré avec tous les secrets
- [ ] Base de données migrée depuis Render
- [ ] DNS configuré (`magjury.org` → `72.62.30.117`)
- [ ] Certificats SSL Let's Encrypt obtenus
- [ ] Application accessible en HTTPS
- [ ] Redirection HTTP → HTTPS fonctionnelle
- [ ] Action Cable (WebSockets) fonctionnel
- [ ] Uploads Cloudinary opérationnels
- [ ] Backups automatiques configurés
- [ ] Auto-renouvellement SSL configuré

---

## 🎉 FÉLICITATIONS !

Votre application **MAGJURY** est maintenant déployée sur votre VPS Hostinger avec :
- ✅ Architecture Docker Compose optimisée
- ✅ SSL/TLS avec Let's Encrypt
- ✅ PostgreSQL 15 en production
- ✅ Redis pour Action Cable
- ✅ Nginx comme reverse proxy
- ✅ Backups automatiques
- ✅ Cloudinary pour les médias

---

## 📞 SUPPORT

En cas de problème, vérifiez :
1. Les logs : `./deploy.sh --logs`
2. Le statut : `./deploy.sh --status`
3. Les health checks : `docker compose ps`

**Commandes de secours :**
```bash
# Tout redémarrer
docker compose down && docker compose up -d

# Voir l'utilisation mémoire
free -h
docker stats --no-stream
```
