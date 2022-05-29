class UsersController < ApplicationController

  def profile
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!', status: 404 }, status: 404
    end

    user_data = SpiderManager::User.call(params[:id])

    if user_data
      render json: user_data, status: 200
    else
      render json: { 
        msg: 'Please pass in a valid Toyhouse user link!', 
        msg_desc: 'The profile you\'re trying to fetch has custom HTML or it is a locked profile.',
      }, 
      status: 500
    end
  end

end