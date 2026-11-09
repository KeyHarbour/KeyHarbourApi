module KeyHarbourApi
  class Engine < ::Rails::Engine
    initializer "key_harbour_core.encryption_test_key" do
      if Rails.env.test?
        ENV["LOCKBOX_MASTER_KEY"] ||= "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789"
      end
    end    
  end
end
