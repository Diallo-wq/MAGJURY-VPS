#!/bin/bash
# Entrypoint pour le conteneur Rails MAGJURY
# Gère les migrations et le démarrage de l'application

set -e

echo "🚀 MAGJURY - Initialisation du conteneur..."

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente de PostgreSQL..."
until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' 2>/dev/null; do
  echo "PostgreSQL non disponible - attente 2s..."
  sleep 2
done
echo "✅ PostgreSQL est prêt!"

# Création de la base si elle n'existe pas
echo "📦 Vérification de la base de données..."
bundle exec rails db:create 2>/dev/null || echo "Base de données déjà existante"

# Exécution des migrations
echo "🔄 Exécution des migrations..."
bundle exec rails db:migrate

# Démarrage de l'application
echo "✅ Démarrage de MAGJURY..."
exec "$@"
