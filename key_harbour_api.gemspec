require_relative "lib/key_harbour_api/version"

Gem::Specification.new do |spec|
  spec.name        = "key_harbour_api"
  spec.version     = KeyHarbourApi::VERSION
  spec.authors     = [ "Denis Fabien" ]
  spec.email       = [ "denis@keyharbour.ca" ]
  spec.homepage    = "https://keyharbour.ca"
  spec.summary     = "Gem to handle API for Keyharbour"
  spec.description = "KeyHarbour gives DevSecOps and IT teams one governed place for their operational data: infrastructure state files, inter-pipeline artifacts, software licenses, and tokens. Deploy on-premises, in any cloud, or as SaaS, according to your compliance requirements."
  spec.license     = "Apache 2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/KeyHarbour/KeyHarbourApi"
  spec.metadata["changelog_uri"] = "https://github.com/KeyHarbour/KeyHarbourApi/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.1.3.1"
end
