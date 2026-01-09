# 🔍 HEALTH CHECK ENDPOINT
# Endpoint simple pour vérifier que l'application Rails fonctionne
# Utilisé par Docker healthcheck et monitoring externe

class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def show
    # Vérification de la connexion à la base de données
    ActiveRecord::Base.connection.execute('SELECT 1')
    
    # Vérification de la connexion à Redis (si Action Cable utilisé)
    if defined?(ActionCable)
      redis_config = ActionCable.server.config.cable
      if redis_config[:adapter] == 'redis'
        # Test de connexion Redis
        redis_url = ENV['REDIS_URL'] || redis_config[:url]
        redis = Redis.new(url: redis_url)
        redis.ping
      end
    end
    
    render json: { 
      status: 'ok',
      timestamp: Time.current.iso8601,
      version: Rails.version,
      environment: Rails.env
    }, status: :ok
    
  rescue => e
    render json: { 
      status: 'error',
      message: e.message,
      timestamp: Time.current.iso8601
    }, status: :service_unavailable
  end
end
