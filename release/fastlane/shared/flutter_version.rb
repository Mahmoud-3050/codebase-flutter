# frozen_string_literal: true

# Reads and writes the Flutter `version: x.y.z+build` line in pubspec.yaml.
module FlutterVersion
  UI = defined?(FastlaneCore::UI) ? FastlaneCore::UI : ::UI

  def self.pubspec_override=(path)
    @pubspec_override = path
  end

  def self.pubspec
    @pubspec_override || DeployConfig.project_path('pubspec.yaml')
  end

  LOCKED_STATES = %w[
    READY_FOR_SALE
    WAITING_FOR_REVIEW
    IN_REVIEW
    PENDING_DEVELOPER_RELEASE
    PROCESSING_FOR_APP_STORE
    PENDING_APPLE_RELEASE
  ].freeze

  def self.current
    contents = File.read(pubspec)
    line = contents[/^version:\s*(.+)$/, 1]
    UI.user_error!("No version: line found in #{pubspec}") if line.nil?

    name, build = line.strip.split('+', 2)
    { name: name, build: (build || '0').to_i }
  end

  def self.write(name:, build:)
    contents = File.read(pubspec).sub(/^version:\s*.+$/, "version: #{name}+#{build}")
    File.write(pubspec, contents)
  end

  def self.next_build_number(store_numbers)
    [*store_numbers, current[:build]].compact.map(&:to_i).max + 1
  end

  def self.bump_patch(name)
    parts = name.split('.')
    UI.user_error!("Version name '#{name}' is not MAJOR.MINOR.PATCH") if parts.size < 3

    major, minor, patch = parts.take(3).map(&:to_i)
    "#{major}.#{minor}.#{patch + 1}"
  end

  def self.ios_version_locked?(version_name, bundle_id)
    app = Spaceship::ConnectAPI::App.find(bundle_id)
    return false if app.nil?

    versions = app.get_app_store_versions
    match = versions.find { |item| item.version_string == version_name }
    return false if match.nil?

    LOCKED_STATES.include?(match.app_store_state.to_s)
  rescue StandardError => e
    UI.important("Could not determine App Store version state: #{e.message}")
    false
  end
end
