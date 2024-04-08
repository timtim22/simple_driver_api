require 'rails_helper'

RSpec.describe BlobData, type: :model do
  it 'is valid with valid attributes' do
    blob = Blob.create(id: SecureRandom.uuid, size: 100, storage_backend: 'database')
    blob_data = blob.build_blob_data(data: 'some_data')
    expect(blob_data).to be_valid
  end

  it 'is not valid without data' do
    blob_data = BlobData.new
    expect(blob_data).not_to be_valid
    expect(blob_data.errors[:data]).to include("can't be blank")
  end

  describe 'Associations' do
    it { should belong_to(:blob) }
  end
end
