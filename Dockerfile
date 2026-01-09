# Dockerfile multi-stage optimisé pour MAGJURY
# Ruby 3.1.4 + Rails 7.0.10 + Production VPS

# ============================================
# STAGE 1: Builder (Installation des dépendances)
# ============================================
FROM ruby:3.1.4-slim AS builder

# Installation des dépendances système pour build
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    git \
    curl \
    libvips \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Définition du répertoire de travail
WORKDIR /app

# Copie des fichiers de dépendances
COPY Gemfile Gemfile.lock ./

# Installation des gems (avec cache optimisé)
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# ============================================
# STAGE 2: Production (Image finale légère)
# ============================================
FROM ruby:3.1.4-slim

# Installation des dépendances runtime uniquement
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    libpq5 \
    nodejs \
    curl \
    libvips \
    imagemagick \
    postgresql-client \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Création de l'utilisateur non-root pour sécurité
RUN groupadd -r magjury && useradd -r -g magjury magjury

# Définition du répertoire de travail
WORKDIR /app

# Copie des gems depuis le builder
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copie du code de l'application
COPY --chown=magjury:magjury . .

# Précompilation des assets (nécessaire pour production)
RUN SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rails assets:precompile

# Création des dossiers nécessaires
RUN mkdir -p tmp/pids tmp/sockets log storage && \
    chown -R magjury:magjury tmp log storage

# Exposition du port Puma
EXPOSE 3000

# Exécution en tant qu'utilisateur non-root
USER magjury

# Script d'entrypoint pour migrations automatiques
COPY --chown=magjury:magjury docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]

# Commande par défaut: démarrage de Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
