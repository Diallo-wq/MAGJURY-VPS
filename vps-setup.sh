#!/bin/bash
# ==============================================
# SCRIPT D'INSTALLATION INITIALE VPS
# À exécuter sur le VPS Ubuntu 24.04
# ==============================================

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_step() {
    echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}\n"
}

# Vérification que c'est bien Ubuntu
if [ ! -f /etc/lsb-release ]; then
    log_error "Ce script est conçu pour Ubuntu uniquement"
    exit 1
fi

source /etc/lsb-release
if [ "$DISTRIB_ID" != "Ubuntu" ]; then
    log_error "Ce script nécessite Ubuntu"
    exit 1
fi

log_step "🚀 INSTALLATION MAGJURY VPS - Ubuntu $DISTRIB_RELEASE"

# ============================================
# ÉTAPE 1: Mise à jour du système
# ============================================
log_step "📦 ÉTAPE 1: Mise à jour du système"
apt update
apt upgrade -y
log_info "Système mis à jour"

# ============================================
# ÉTAPE 2: Installation des outils de base
# ============================================
log_step "🔧 ÉTAPE 2: Installation des outils de base"
apt install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    ufw \
    fail2ban \
    htop \
    net-tools \
    dnsutils

log_info "Outils de base installés"

# ============================================
# ÉTAPE 3: Configuration du firewall
# ============================================
log_step "🔒 ÉTAPE 3: Configuration du firewall (UFW)"
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw --force enable
log_info "Firewall configuré"
ufw status numbered

# ============================================
# ÉTAPE 4: Installation de Docker
# ============================================
log_step "🐳 ÉTAPE 4: Installation de Docker"

if command -v docker &> /dev/null; then
    log_warning "Docker est déjà installé ($(docker --version))"
else
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    log_info "Docker installé avec succès"
fi

docker --version

# ============================================
# ÉTAPE 5: Installation de Docker Compose
# ============================================
log_step "📦 ÉTAPE 5: Installation de Docker Compose"

if command -v docker-compose &> /dev/null; then
    log_warning "Docker Compose est déjà installé ($(docker-compose --version))"
else
    # Essayer d'installer le plugin
    apt install -y docker-compose-plugin 2>/dev/null || {
        # Si le plugin n'est pas dispo, installer standalone
        DOCKER_COMPOSE_VERSION="v2.24.0"
        curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
            -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        log_info "Docker Compose standalone installé"
    }
fi

docker compose version || docker-compose --version

# ============================================
# ÉTAPE 6: Installation de Certbot
# ============================================
log_step "🔐 ÉTAPE 6: Installation de Certbot (Let's Encrypt)"

if command -v certbot &> /dev/null; then
    log_warning "Certbot est déjà installé ($(certbot --version))"
else
    apt install -y certbot python3-certbot-nginx
    log_info "Certbot installé"
fi

certbot --version

# ============================================
# ÉTAPE 7: Configuration de Fail2ban
# ============================================
log_step "🛡️  ÉTAPE 7: Configuration de Fail2ban"
systemctl enable fail2ban
systemctl start fail2ban
log_info "Fail2ban activé"

# ============================================
# ÉTAPE 8: Création de la structure de répertoires
# ============================================
log_step "📁 ÉTAPE 8: Création de la structure de répertoires"
mkdir -p /var/www/magjury
mkdir -p /var/www/certbot
log_info "Répertoires créés"

# ============================================
# ÉTAPE 9: Installation de PostgreSQL client
# ============================================
log_step "🐘 ÉTAPE 9: Installation du client PostgreSQL"
apt install -y postgresql-client
log_info "Client PostgreSQL installé"

# ============================================
# RÉSUMÉ
# ============================================
log_step "✅ INSTALLATION TERMINÉE"

echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         INSTALLATION RÉUSSIE !                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📊 Résumé de l'installation:${NC}"
echo ""
echo "✓ Système: Ubuntu $DISTRIB_RELEASE"
echo "✓ Docker: $(docker --version | cut -d',' -f1)"
echo "✓ Docker Compose: Installé"
echo "✓ Certbot: $(certbot --version | head -n1)"
echo "✓ Firewall: Actif (ports 22, 80, 443)"
echo "✓ Fail2ban: Actif"
echo "✓ PostgreSQL client: Installé"
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PROCHAINES ÉTAPES:${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════${NC}"
echo ""
echo "1. Cloner le projet MAGJURY:"
echo "   cd /var/www/magjury"
echo "   git clone https://github.com/Katcho555/cash_liquid.git ."
echo "   git checkout develop"
echo ""
echo "2. Configurer les secrets:"
echo "   cp .env.example .env"
echo "   nano .env"
echo ""
echo "3. Générer des mots de passe sécurisés:"
echo "   openssl rand -base64 32  # Pour POSTGRES_PASSWORD"
echo "   openssl rand -base64 32  # Pour REDIS_PASSWORD"
echo ""
echo "4. Rendre les scripts exécutables:"
echo "   chmod +x deploy.sh db-backup.sh docker-entrypoint.sh"
echo ""
echo "5. Migrer la base de données depuis Render (voir MIGRATION_GUIDE.md)"
echo ""
echo "6. Lancer le premier déploiement:"
echo "   ./deploy.sh --first-deploy"
echo ""
echo "7. Configurer DNS puis SSL (voir MIGRATION_GUIDE.md)"
echo ""
echo -e "${GREEN}📖 Consultez MIGRATION_GUIDE.md pour le guide complet${NC}"
echo ""
