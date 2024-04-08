require 'rails_helper'

RSpec.describe BlobStorageService do
  let(:blob) { create(:blob) }
  let(:data) { "some data" }

  describe ".store" do
    before do
      allow(ENV).to receive(:[]).with('STORAGE_BACKEND').and_return(storage_backend)
    end

    context "when storing in s3" do
      let(:storage_backend) { 's3' }

      it "returns true on success" do
        allow(described_class).to receive(:store_in_s3).with(blob, data).and_return(true)
        expect(described_class.store(blob, data)).to be(true)
      end

      it "returns false on failure" do
        allow(described_class).to receive(:store_in_s3).with(blob, data).and_return(false)
        expect(described_class.store(blob, data)).to be(false)
      end
    end

    # We could repeat something similar for 'local', 'ftp', 'database' storage backends
  end

  describe ".store_in_s3" do
    it "logs an error on failure" do
      expect(Rails.logger).to receive(:error).with(/Failed to store blob/)
      described_class.store_in_s3(blob, data)
    end
  end

  # We could repeat Similar tests for .store_locally, .store_in_database, and .store_ftp
end
