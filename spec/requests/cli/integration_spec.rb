require 'rails_helper'

RSpec.describe "Intégration Réelle CLI Go", type: :request do
  before(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end    
  fixtures :all 
  BASE_DIR = Rails.root.join("vendor", "cli")
  SOURCE_DIR = BASE_DIR.join("kh")
  BIN_PATH = SOURCE_DIR.join("bin")
  SERVER_HOST = '127.0.0.1'
  SERVER_PORT = 3001

  before(:all) do
    puts "\n🔨 Création des folders..."
    system("mkdir -p #{BASE_DIR}")
    puts "\n🔨 Compilation du CLI Go..."
    system("cd #{BASE_DIR} && git clone --depth 1 --branch main https://github.com/KeyHarbour/kh.git")
    system("mkdir -p #{BIN_PATH}")
    system("cd #{SOURCE_DIR} && pwd && go build -o #{BIN_PATH} ./cmd/kh")
    puts "🚀 Démarrage du serveur Rails de test sur le port 3001..."
    @server_thread = Thread.new do
      require 'rack/handler/puma'
      Rack::Handler::Puma.run(
        Rails.application, 
        Port: SERVER_PORT, 
        Host: SERVER_HOST, 
        Silent: true
      )
    end
    unless File.exist?(BIN_PATH)
      raise "Erreur : Impossible de compiler le binaire Go dans #{BIN_PATH}"
    end
  end

  after(:all) do
    FileUtils.rm_rf(BASE_DIR)
  end

  describe "Exécution des commandes du CLI pour les KV" do   
    before(:context) do
      self.use_transactional_tests = false
    end    

    it "valide que le binaire communique avec succès avec Rails" do
      environment = environments(:production10)
      workspace = workspaces(:app_fivetran)
      token = tokens(:data_org).generate_token_for(:statefile)
      expected_result = [{"key" => "ws1_test_key", "value" => "ws1_test_value", "expires_at" => nil, "private" => false, "environment" => environment.name}]

      env_vars = [
        "KH_ENDPOINT=http://#{SERVER_HOST}:#{SERVER_PORT}/api/v2",
        "KH_INSECURE=1",
        "KH_PROJECT=#{workspace.project.uuid}",
        "KH_WORKSPACE=#{workspace.uuid}",
        "KH_TOKEN=#{token}"
      ]
      
      # Variable d'environnement et arguments passés au binaire Go
      cmd = "#{env_vars.join(' ')} #{BIN_PATH}/kh kv ls --debug -o json"
      stdout_str, stderr_str = "", ""
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        stdout_str = stdout.read
        stderr_str = stderr.read
      end
      if $?.exitstatus != 0
        puts "\n❌ LE CLI GO A ÉCHOUÉ (Code de sortie: #{$?.exitstatus})"
        puts "💬 Sortie (stdout): #{stdout_str.inspect}"
        puts "⚠️  Erreur (stderr): #{stderr_str.inspect}"
      end
      begin
        json_response = JSON.parse(stdout_str)
      rescue JSON::ParserError
        raise "Erreur : La sortie du CLI Go n'est pas un JSON valide. Sortie brute : #{stdout_str.inspect}"
      end

      expect($?.exitstatus).to eq(0)
      expect(json_response).to eq(expected_result)
    end
  end
end
