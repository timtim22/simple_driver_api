FactoryBot.define do
  factory :blob do
    id { SecureRandom.uuid }
    size { 1024 }
    storage_backend { "local" }
    
    after(:create) do |blob|
      create(:blob_data, blob: blob, data: "Some test data") 
    end
  end
end
