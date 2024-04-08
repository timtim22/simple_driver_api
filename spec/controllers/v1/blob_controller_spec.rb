require 'rails_helper'

RSpec.describe V1::BlobsController, type: :controller do
  describe "POST #create" do
    let(:valid_attributes) {
      { id: "unique_id", data: Base64.strict_encode64("SGVsbG8sIFNpbXBsZSBTdG9yYWdlIFdvcmxkIQ==") }
    }

    let(:invalid_attributes) {
      { data: "not_base64_data" }
    }

    before do
      allow_any_instance_of(V1::BlobsController).to receive(:authenticate).and_return(true)
    end

    context "with valid params" do
      it "creates a new Blob" do
        allow(BlobStorageService).to receive(:store).and_return(true)
        
        expect {
          post :create, params: valid_attributes
        }.to change(Blob, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid Base64 data" do
      it "returns a bad request status" do
        post :create, params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when storage service fails" do
      it "does not create a blob" do
        allow(BlobStorageService).to receive(:store).and_return(false)

        expect {
          post :create, params: valid_attributes
        }.to_not change(Blob, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET #show" do

    before do
      allow_any_instance_of(V1::BlobsController).to receive(:authenticate).and_return(true)
    end

    context "with a valid blob ID" do
      it "returns the blob data" do
        blob = FactoryBot.create(:blob)
        get :show, params: { id: blob.id }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(blob.id)
      end
    end
  
    context "with an invalid blob ID" do
      it "returns not found status" do
        get :show, params: { id: "invalid_id" }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
