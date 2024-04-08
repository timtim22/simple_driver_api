class BlobData < ApplicationRecord
  belongs_to :blob, primary_key: :id, foreign_key: :blob_id

  validates :data, presence: true
end