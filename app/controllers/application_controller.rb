class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  private

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
