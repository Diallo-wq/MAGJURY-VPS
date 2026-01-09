class BidsController < ApplicationController
  before_action :set_bid, only: %i[ show edit update destroy ]
  before_action :set_auction  
  before_action :authenticate_user!
  # GET /bids or /bids.json
  def index
    @bids = Bid.all
  end

  # GET /bids/1 or /bids/1.json
  def show
  end

  # GET /bids/new
  def new
    @bid = Bid.new
  end

  # GET /bids/1/edit
  def edit
  end

  # POST /bids or /bids.json
  

  def create
    @bid = @auction.bids.new(bid_params.merge(user: current_user))

    # Vérif montant côté serveur
    if @bid.montant <= @auction.prix_actuel
      flash[:alert] = "La mise doit être supérieure à #{number_to_currency(@auction.prix_actuel, unit: devise)}."
      redirect_to @auction and return
    end

    if @bid.save
      @auction.update!(prix_actuel: @bid.montant, nombre_mises: @auction.bids.count)
      redirect_to @auction, notice: "Mise enregistrée !"
    else
      render "auctions/show"
    end
  end

  # PATCH/PUT /bids/1 or /bids/1.json
  def update
    respond_to do |format|
      if @bid.update(bid_params)
        format.html { redirect_to @bid, notice: "Bid was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @bid }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bid.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bids/1 or /bids/1.json
  def destroy
    @bid.destroy

    respond_to do |format|
      format.html { redirect_to bids_path, notice: "Bid was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bid
      @bid = Bid.find(params[:id])
    end

    def set_auction
      @auction = Auction.find(params[:auction_id])
    end

    # Only allow a list of trusted parameters through.
    def bid_params
      params.require(:bid).permit(:montant, :user_id, :auction_id)
    end
end
