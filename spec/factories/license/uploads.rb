FactoryBot.define do
  factory :license_upload, class: 'License::Upload' do
    instance { nil }
    status { 1 }
  end
end
