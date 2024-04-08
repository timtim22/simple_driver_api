FactoryBot.define do
  factory :blob_data do
    blob
    data { "Test blob data" }
  end
end
