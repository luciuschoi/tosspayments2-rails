# frozen_string_literal: true

require_relative 'lib/tosspayments2/rails/version'

Gem::Specification.new do |spec|
  spec.name = 'tosspayments2-rails'
  spec.version = Tosspayments2::Rails::VERSION
  spec.authors = ['Lucius Choi']
  spec.email = ['lucius.choi@gmail.com']

  spec.summary = 'TossPayments v2 (Payment Widget) integration helpers for Rails 7 & 8'
  spec.description = 'Rails engine & helpers to integrate TossPayments online payments '
  spec.description += '(script tag helper, configuration, server-side confirm API wrapper, generator).'
  spec.homepage = 'https://github.com/luciuschoi/tosspayments2-rails'
  spec.required_ruby_version = '>= 3.2.0'
  spec.license = 'MIT'

  # Remove allowed_push_host (unnecessary for RubyGems.org). Leave commented if private gem server planned.
  # spec.metadata["allowed_push_host"] = "https://example.com"
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/luciuschoi/tosspayments2-rails'
  spec.metadata['changelog_uri'] = 'https://github.com/luciuschoi/tosspayments2-rails/blob/main/CHANGELOG.md'
  spec.metadata['documentation_uri'] = 'https://www.rubydoc.info/gems/tosspayments2-rails'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore pkg/]) ||
        f.end_with?('.gem')
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'rails', '>= 7.0', '< 9.0'

  # Development dependencies now declared in Gemfile groups.

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
