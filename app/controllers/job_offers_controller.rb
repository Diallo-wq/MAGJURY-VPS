# app/controllers/job_offers_controller.rb
class JobOffersController < ApplicationController
  before_action :authenticate_user!, except: %i[emplois show]
  before_action :require_admin!, except: [:emplois, :show]
  before_action :set_job_offer, only: %i[show edit update destroy]
  layout 'dashboard', except: [:emplois]
  # PUBLIC
  def emplois
    @job_offers = JobOffer.published.recent
    @categories = JobOffer.published.select(:contract_type).distinct.pluck(:contract_type).map { |c| [JobOffer.human_attribute_name("contract_type.#{c}"), c] }

    # Filtres
    @job_offers = @job_offers.where(contract_type: params[:contract_type]) if params[:contract_type].present?
    @job_offers = @job_offers.where(remote: true) if params[:remote] == "1"
    @job_offers = @job_offers.where("location ILIKE ?", "%#{params[:q]}%") if params[:q].present?

    # Tri
    @job_offers = @job_offers.order(created_at: :desc) if params[:sort] == "date_desc"
    @job_offers = @job_offers.order("salary DESC") if params[:sort] == "salary_desc"
  end

  def show; end

  # ADMIN
  def index
    @job_offers = JobOffer.order(created_at: :desc)
    filter_collection if params[:commit].present?
  end

  def new
    @job_offer = JobOffer.new
  end

  def create
    @job_offer = JobOffer.new(job_offer_params)
    if @job_offer.save
      redirect_to job_offers_path, notice: "Offre publiée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @job_offer.update(job_offer_params)
      redirect_to job_offers_path, notice: "Offre mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job_offer.destroy
    redirect_to job_offers_path, alert: "Offre supprimée."
  end

  private

  def set_job_offer
    @job_offer = JobOffer.find(params[:id])
  end

  def filter_collection
    @job_offers = @job_offers.where(contract_type: params[:contract_type]) if params[:contract_type].present?
    @job_offers = @job_offers.where(remote: true) if params[:remote] == "1"
    @job_offers = @job_offers.where("location ILIKE ?", "%#{params[:location]}%") if params[:location].present?
  end

  def job_offer_params
    params.require(:job_offer).permit(:title, :company, :location, :contract_type, :remote, :salary, :description, :contact_phone, :active)
  end
end