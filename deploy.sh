#!/bin/bash
# ==============================================
# SCRIPT DE DÉPLOIEMENT MAGJURY VPS
# ==============================================
# Usage: ./deploy.sh [options]
# Options:
#   --first-deploy : Premier déploiement (avec migration DB)
#   --update       : Mise à jour simple (rebuild + restart)
#   --rollback     : Rollback à la version précédente

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
APP_DIR="/var/www/magjury"
BACKUP_DIR="$APP_DIR/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Fonctions helper
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    if [ ! -f "$APP_DIR/.env" ]; then
        log_error "Fichier .env manquant ! Copiez .env.example et configurez-le."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé !"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose n'est pas installé !"
        exit 1
    fi
    
    log_info "✅ Prérequis validés"
}

# Backup de la base de données
backup_database() {
    log_info "💾 Création d'un backup de la base de données..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Lecture de la config depuis .env
    source "$APP_DIR/.env"
    
    docker exec magjury_db pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" \
        > "$BACKUP_DIR/magjury_backup_$DATE.sql"
    
    # Compression du backup
    gzip "$BACKUP_DIR/magjury_backup_$DATE.sql"
    
    log_info "✅ Backup créé: magjury_backup_$DATE.sql.gz"
    
    # Nettoyage des anciens backups (garde les 7 derniers)
    cd "$BACKUP_DIR"
    ls -t magjury_backup_*.sql.gz | tail -n +8 | xargs -r rm
    log_info "🗑️ Anciens backups nettoyés"
}

# Premier déploiement
first_deploy() {
    log_info "🚀 Premier déploiement de MAGJURY..."
    
    cd "$APP_DIR"
    
    # Pull du code
    log_info "📥 Récupération du code..."
    git pull origin develop
    
    # Build des images
    log_info "🔨 Construction des images Docker..."
    docker-compose build --no-cache
    
    # Démarrage des services
    log_info "🚀 Démarrage des services..."
    docker-compose up -d
    
    # Attente que les services soient prêts
    log_info "⏳ Attente du démarrage des services..."
    sleep 30
    
    # Vérification du statut
    docker-compose ps
    
    log_info "✅ Premier déploiement terminé !"
    log_warning "⚠️ N'oubliez pas de configurer Let's Encrypt ensuite !"
}

# Mise à jour
update_deploy() {
    log_info "🔄 Mise à jour de MAGJURY..."
    
    cd "$APP_DIR"
    
    # Backup avant mise à jour
    backup_database
    
    # Pull du code
    log_info "📥 Récupération des dernières modifications..."
    git pull origin develop
    
    # Rebuild et restart
    log_info "🔨 Reconstruction et redémarrage..."
    docker-compose build app
    docker-compose up -d --no-deps --force-recreate app
    
    # Logs pour vérification
    log_info "📋 Logs de l'application:"
    docker-compose logs --tail=50 app
    
    log_info "✅ Mise à jour terminée !"
}

# Rollback
rollback_deploy() {
    log_info "⏪ Rollback de MAGJURY..."
    
    cd "$APP_DIR"
    
    # Liste des backups disponibles
    log_info "Backups disponibles:"
    ls -lh "$BACKUP_DIR"/*.sql.gz
    
    read -p "Entrez le nom du fichier de backup à restaurer: " backup_file
    
    if [ ! -f "$BACKUP_DIR/$backup_file" ]; then
        log_error "Fichier de backup introuvable !"
        exit 1
    fi
    
    # Restauration
    log_warning "⚠️ Arrêt de l'application..."
    docker-compose stop app
    
    log_info "📥 Restauration de la base de données..."
    source "$APP_DIR/.env"
    
    gunzip -c "$BACKUP_DIR/$backup_file" | docker exec -i magjury_db \
        psql -U "$POSTGRES_USER" "$POSTGRES_DB"
    
    log_info "🔄 Redémarrage..."
    docker-compose up -d
    
    log_info "✅ Rollback terminé !"
}

# Affichage des logs
show_logs() {
    cd "$APP_DIR"
    docker-compose logs -f --tail=100
}

# Statut des services
show_status() {
    cd "$APP_DIR"
    log_info "📊 Statut des services:"
    docker-compose ps
    echo ""
    log_info "💾 Utilisation des volumes:"
    docker volume ls | grep magjury
    echo ""
    log_info "🌐 Ports exposés:"
    docker-compose port nginx 443 || echo "HTTPS non configuré"
    docker-compose port nginx 80
}

# Menu principal
case "${1:-}" in
    --first-deploy)
        check_prerequisites
        first_deploy
        ;;
    --update)
        check_prerequisites
        update_deploy
        ;;
    --rollback)
        check_prerequisites
        rollback_deploy
        ;;
    --logs)
        show_logs
        ;;
    --status)
        show_status
        ;;
    --backup)
        check_prerequisites
        backup_database
        ;;
    *)
        echo "Usage: $0 [--first-deploy|--update|--rollback|--logs|--status|--backup]"
        echo ""
        echo "Options:"
        echo "  --first-deploy : Premier déploiement complet"
        echo "  --update       : Mise à jour de l'application"
        echo "  --rollback     : Rollback avec restauration DB"
        echo "  --logs         : Afficher les logs en temps réel"
        echo "  --status       : Afficher le statut des services"
        echo "  --backup       : Créer un backup manuel de la DB"
        exit 1
        ;;
esac
