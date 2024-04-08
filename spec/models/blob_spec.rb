require 'rails_helper'

RSpec.describe Blob, type: :model do
  it 'is valid with valid attributes' do
    blob = Blob.new(id: SecureRandom.uuid, size: 100, storage_backend: 'local')
    expect(blob).to be_valid
  end

  it 'is not valid without a size' do
    blob = Blob.new(storage_backend: 's3')
    expect(blob).not_to be_valid
    expect(blob.errors[:size]).to include("can't be blank")
  end

  it 'is not valid without a storage_backend' do
    blob = Blob.new(size: 100)
    expect(blob).not_to be_valid
    expect(blob.errors[:storage_backend]).to include("can't be blank")
  end

  it 'is not valid with an unsupported storage_backend' do
    blob = Blob.new(size: 100, storage_backend: 'unsupported_backend')
    expect(blob).not_to be_valid
    expect(blob.errors[:storage_backend]).to include("is not included in the list")
  end

  describe 'Associations' do
    it { should have_one(:blob_data).dependent(:destroy) }
  end
end
