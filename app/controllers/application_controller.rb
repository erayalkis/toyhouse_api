class ApplicationController < ActionController::API

  def app_status 
    render json: { status: 200, msg: 'Application Online'  }, status: :ok
  end

end
