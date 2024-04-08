class V1::BlobsController < ApplicationController
  before_action :authenticate

  def create
    return render json: { error: "Invalid Base64 data" }, status: :bad_request unless valid_base64?(params[:data])

    decoded_data = Base64.decode64(params[:data])
    blob = initialize_blob(decoded_data)
    if BlobStorageService.store(blob, decoded_data) && blob.save
      render_blob(blob, :created, params[:data])
    else
      render json: { errors: blob.errors.full_messages.presence || "Failed to store blob data" }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    blob = Blob.find_by(id: params[:id])
    return render json: { error: "Blob not found" }, status: :not_found unless blob

    encoded_data = Base64.strict_encode64(blob.blob_data.data)
    render_blob(blob, nil, encoded_data)
  end

  private

  def valid_base64?(data)
    data.match?(/\A(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?\z/)
  end

  def initialize_blob(decoded_data)
    Blob.find_or_initialize_by(id: params[:id]).tap do |blob|
      blob.size = decoded_data.bytesize
      blob.storage_backend = ENV['STORAGE_BACKEND']
    end
  end

  def render_blob(blob, status = nil, data = nil)
    render json: {
      id: blob.id,
      data: data || blob.blob_data&.data,
      size: blob.size,
      created_at: blob.created_at
    }, status: status
  end

  def authenticate
    authenticate_token || render_unauthorized
  end
  
  def authenticate_token
    authenticate_with_http_token do |token, options|
      AuthToken.valid?(token)
    end
  end

  # run the following command in rails console to generate a new token
  # payload = { test: "info", exp: 24.hours.from_now.to_i }
  # token = AuthToken.issue_token(payload)
  
end
