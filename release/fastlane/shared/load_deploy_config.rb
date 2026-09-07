# frozen_string_literal: true

# Loads `release/deploy.config` into ENV for Fastlane lanes.
# ROOT is the Flutter project (pubspec.yaml). RELEASE_DIR is this automation folder.
module DeployConfig
  RELEASE_DIR = File.expand_path('../..', __dir__)
  ROOT = File.expand_path('..', RELEASE_DIR)

  def self.load!
    require 'dotenv'
    path = File.join(RELEASE_DIR, 'deploy.config')
    unless File.exist?(path)
      fail!(
        "Missing #{path}. Copy release/deploy.config.example to release/deploy.config and fill in values."
      )
    end
    Dotenv.overload(path)
  end

  def self.secret_path(relative)
    return relative if relative.to_s.start_with?('/')

    File.expand_path(File.join(RELEASE_DIR, relative))
  end

  def self.project_path(*parts)
    File.expand_path(File.join(ROOT, *parts))
  end

  # Hook scripts: prefer a path under release/, otherwise the Flutter project root.
  def self.hook_path(relative)
    return relative if relative.to_s.start_with?('/')

    in_release = File.expand_path(File.join(RELEASE_DIR, relative))
    return in_release if File.file?(in_release)

    File.expand_path(File.join(ROOT, relative))
  end

  def self.truthy?(key, default: 'false')
    %w[1 true yes].include?(ENV.fetch(key, default).strip.downcase)
  end

  def self.fail!(message)
    if defined?(UI)
      UI.user_error!(message)
    else
      abort("error: #{message}")
    end
  end
end
