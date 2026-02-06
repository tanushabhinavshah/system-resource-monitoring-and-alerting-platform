class CpuAllocationsController < ApplicationController
  # GET /cpu-allocation
  def show
    response.headers['Cache-Control'] = 'no-store'
    render json: CpuAllocation.last
  end
end