class ThresholdsController < ApplicationController
  # GET /threshold
  def show
    render json: Threshold.first
  end

  # PATCH /threshold
  def update
    @threshold = Threshold.first

    if @threshold.update(threshold_params)
      render json: @threshold
    else
      render json: @threshold.errors, status: :unprocessable_entity
    end
  end

  private

  # "Strong Parameters" - a security feature in Rails.
  # We only allow these specific fields to be changed.
  def threshold_params
    params.require(:threshold).permit(:cpu_threshold, :memory_threshold, :network_in_threshold, :network_out_threshold)
  end
end