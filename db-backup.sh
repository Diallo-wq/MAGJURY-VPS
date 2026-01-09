#!/bin/bash
# ==============================================
# SCRIPT DE BACKUP/RESTORE POSTGRESQL MAGJURY
# ==============================================

set -e

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_DIR="/var/www/magjury"
BACKUP_DIR="$APP_DIR/backups"
DATE=$(date +%Y%m%d_%H%M%S)

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Backup de la base de données
backup_database() {
    log_info "💾 Création d'un backup de la base de données..."
    
    # Charger les variables d'environnement
    if [ ! -f "$APP_DIR/.env" ]; then
        log_error "Fichier .env introuvable !"
        exit 1
    fi
    
    source "$APP_DIR/.env"
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup avec format custom (compressé)
    docker exec magjury_db pg_dump \
        -U "$POSTGRES_USER" \
        -d "$POSTGRES_DB" \
        -Fc \
        > "$BACKUP_DIR/magjury_backup_$DATE.dump"
    
    # Également créer une version SQL plain pour faciliter l'inspection
    docker exec magjury_db pg_dump \
        -U "$POSTGRES_USER" \
        -d "$POSTGRES_DB" \
        > "$BACKUP_DIR/magjury_backup_$DATE.sql"
    
    # Compression du fichier SQL
    gzip "$BACKUP_DIR/magjury_backup_$DATE.sql"
    
    # Calcul de la taille
    SIZE=$(du -h "$BACKUP_DIR/magjury_backup_$DATE.dump" | cut -f1)
    
    log_info "✅ Backup créé avec succès !"
    log_info "   📁 Fichier: magjury_backup_$DATE.dump ($SIZE)"
    log_info "   📁 Fichier SQL: magjury_backup_$DATE.sql.gz"
    
    # Nettoyage des anciens backups (garde les 10 derniers)
    cd "$BACKUP_DIR"
    ls -t magjury_backup_*.dump 2>/dev/null | tail -n +11 | xargs -r rm
    ls -t magjury_backup_*.sql.gz 2>/dev/null | tail -n +11 | xargs -r rm
    
    log_info "🗑️  Anciens backups nettoyés (garde les 10 derniers)"
}

# Restauration de la base de données
restore_database() {
    log_warning "⚠️  ATTENTION: Cette opération va ÉCRASER la base de données actuelle !"
    
    # Liste des backups disponibles
    log_info "📋 Backups disponibles:"
    echo ""
    ls -lh "$BACKUP_DIR"/*.dump 2>/dev/null || log_error "Aucun backup trouvé !"
    echo ""
    
    read -p "Entrez le nom du fichier de backup à restaurer (ex: magjury_backup_20260110_020000.dump): " backup_file
    
    if [ ! -f "$BACKUP_DIR/$backup_file" ]; then
        log_error "Fichier de backup introuvable: $BACKUP_DIR/$backup_file"
        exit 1
    fi
    
    read -p "Êtes-vous SÛR de vouloir restaurer ce backup ? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        log_info "Restauration annulée."
        exit 0
    fi
    
    # Charger les variables d'environnement
    source "$APP_DIR/.env"
    
    # Arrêt de l'application pour éviter les connexions actives
    log_warning "🛑 Arrêt de l'application..."
    cd "$APP_DIR"
    docker compose stop app
    
    # Déconnexion de tous les utilisateurs
    log_info "🔌 Déconnexion des sessions actives..."
    docker exec magjury_db psql -U "$POSTGRES_USER" -d postgres -c \
        "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$POSTGRES_DB' AND pid <> pg_backend_pid();"
    
    # Suppression et recréation de la base
    log_info "🗑️  Suppression de la base actuelle..."
    docker exec magjury_db psql -U "$POSTGRES_USER" -d postgres -c "DROP DATABASE IF EXISTS $POSTGRES_DB;"
    
    log_info "📦 Création d'une nouvelle base..."
    docker exec magjury_db psql -U "$POSTGRES_USER" -d postgres -c "CREATE DATABASE $POSTGRES_DB;"
    
    # Restauration
    log_info "📥 Restauration du backup..."
    cat "$BACKUP_DIR/$backup_file" | docker exec -i magjury_db \
        pg_restore --no-acl --no-owner -U "$POSTGRES_USER" -d "$POSTGRES_DB"
    
    log_info "✅ Restauration terminée !"
    
    # Redémarrage de l'application
    log_info "🚀 Redémarrage de l'application..."
    docker compose up -d
    
    log_info "✅ Application redémarrée avec succès !"
    log_info "🔍 Vérifiez les logs: docker compose logs -f app"
}

# Backup depuis Render (migration initiale)
backup_from_render() {
    log_info "📥 Backup depuis Render..."
    
    read -p "Entrez l'URL PostgreSQL de Render (format: postgresql://user:pass@host:port/db): " render_url
    
    if [ -z "$render_url" ]; then
        log_error "URL vide !"
        exit 1
    fi
    
    mkdir -p "$BACKUP_DIR"
    
    log_info "🔄 Création du dump depuis Render..."
    pg_dump -Fc --no-acl --no-owner "$render_url" > "$BACKUP_DIR/magjury_render_$DATE.dump"
    
    SIZE=$(du -h "$BACKUP_DIR/magjury_render_$DATE.dump" | cut -f1)
    log_info "✅ Backup Render créé: magjury_render_$DATE.dump ($SIZE)"
}

# Statistiques de la base
database_stats() {
    source "$APP_DIR/.env"
    
    log_info "📊 Statistiques de la base de données:"
    echo ""
    
    # Taille de la base
    docker exec magjury_db psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
        "SELECT pg_size_pretty(pg_database_size('$POSTGRES_DB')) AS database_size;"
    
    echo ""
    
    # Nombre de tables
    docker exec magjury_db psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
        "SELECT COUNT(*) AS table_count FROM information_schema.tables WHERE table_schema = 'public';"
    
    echo ""
    
    # Top 5 des plus grosses tables
    log_info "🔝 Top 5 des tables les plus volumineuses:"
    docker exec magjury_db psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
        "SELECT schemaname || '.' || tablename AS table_name, 
                pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size 
         FROM pg_tables 
         WHERE schemaname = 'public' 
         ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC 
         LIMIT 5;"
}

# Menu principal
case "${1:-}" in
    --backup)
        backup_database
        ;;
    --restore)
        restore_database
        ;;
    --from-render)
        backup_from_render
        ;;
    --stats)
        database_stats
        ;;
    *)
        echo "Usage: $0 [--backup|--restore|--from-render|--stats]"
        echo ""
        echo "Options:"
        echo "  --backup       : Créer un backup de la base actuelle"
        echo "  --restore      : Restaurer un backup existant"
        echo "  --from-render  : Créer un backup depuis Render (migration initiale)"
        echo "  --stats        : Afficher les statistiques de la base"
        exit 1
        ;;
esac
