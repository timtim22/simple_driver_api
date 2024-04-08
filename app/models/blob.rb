class Blob < ApplicationRecord
  has_one :blob_data, primary_key: :id, foreign_key: :blob_id, dependent: :destroy

  # Validation examples
  validates :size, presence: true
  validates :storage_backend, presence: true, inclusion: { in: %w[s3 local ftp database] }
end
