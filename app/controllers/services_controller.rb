# app/controllers/services_controller.rb
class ServicesController < ApplicationController
  before_action :set_service, only: %i[show edit update destroy]
  before_action :require_redacteur!, except: [:offre_de_service]
  layout 'dashboard', except: [:offre_de_service]
  def index
    @services = Service.all.order(created_at: :desc)
  end

  def offre_de_service
     @services = Service.all.order(created_at: :asc)
  end

  def show; end

  def new
    @service = Service.new
  end

  def create
    @service = Service.new(service_params)
    if @service.save
      redirect_to services_path, notice: "Service créé."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @service.update(service_params)
      redirect_to services_path, notice: "Service mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service.destroy
    redirect_to services_path, alert: "Service supprimé."
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.require(:service).permit(:title, :description, :icon, :price, :price_suffix, :category)
  end
end