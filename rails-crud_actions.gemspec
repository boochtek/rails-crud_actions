# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rails-crud_actions}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Craig Buchek"]
  s.date = %q{2009-01-25}
  s.description = %q{Provides default CRUD actions for a Rails controller.}
  s.email = ["craig@boochtek.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["features/development.feature", "features/steps/common.rb", "features/steps/env.rb", "History.txt", "lib/rails-crud_actions.rb", "Manifest.txt", "PostInstall.txt", "Rakefile", "README.rdoc", "spec/rails-crud_actions_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake", "tmp/tests.out"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/boochtek/rails-crud_actions}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rails-crud_actions}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Provides default CRUD actions for a Rails controller.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
