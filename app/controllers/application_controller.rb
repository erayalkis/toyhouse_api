class ApplicationController < ActionController::API

  def app_status 
    render json: { msg: 'Application Online'  }, status: :ok
  end

end
