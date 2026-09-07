# frozen_string_literal: true

# Queries Play and App Store Connect, then writes the next version into pubspec.yaml.
# Android versionCode must increase globally, so the build number is always max+1
# even when the iOS marketing version is bumped because it was locked.
module PrepareVersion
  def self.run(lane)
    current = FlutterVersion.current
    name = current[:name]
    numbers = []

    numbers.concat(play_codes(lane)) unless DeployConfig.truthy?('SKIP_ANDROID')
    numbers.concat(ios_codes(lane, name)) unless DeployConfig.truthy?('SKIP_IOS')

    unless DeployConfig.truthy?('SKIP_IOS')
      bundle_id = ENV.fetch('IOS_BUNDLE_IDENTIFIER')
      if FlutterVersion.ios_version_locked?(name, bundle_id)
        name = FlutterVersion.bump_patch(name)
        UI.important("App Store version was locked; bumping marketing version to #{name}")
      end
    end

    build = FlutterVersion.next_build_number(numbers)
    FlutterVersion.write(name: name, build: build)
    UI.success("Version set to #{name}+#{build}")
  end

  def self.play_codes(lane)
    json_key = DeployConfig.secret_path(ENV.fetch('GOOGLE_PLAY_JSON_KEY'))
    package = ENV.fetch('GOOGLE_PLAY_PACKAGE_NAME')
    tracks = [ENV.fetch('GOOGLE_PLAY_TRACK'), 'production'].uniq
    tracks.flat_map do |track|
      lane.google_play_track_version_codes(
        package_name: package,
        json_key: json_key,
        track: track
      )
    rescue StandardError => e
      UI.important("No version codes on Play track '#{track}': #{e.message}")
      []
    end
  end
  private_class_method :play_codes

  def self.ios_codes(lane, version_name)
    configure_asc!(lane)
    bundle = ENV.fetch('IOS_BUNDLE_IDENTIFIER')
    testflight = lane.latest_testflight_build_number(
      app_identifier: bundle,
      initial_build_number: 0
    )
    store = lane.app_store_build_number(
      app_identifier: bundle,
      live: false,
      version: version_name,
      initial_build_number: 0
    )
    [testflight, store]
  rescue StandardError => e
    UI.important("Could not read App Store build numbers: #{e.message}")
    []
  end
  private_class_method :ios_codes

  def self.configure_asc!(lane)
    lane.app_store_connect_api_key(
      key_id: ENV.fetch('ASC_KEY_ID'),
      issuer_id: ENV.fetch('ASC_ISSUER_ID'),
      key_filepath: DeployConfig.secret_path(ENV.fetch('ASC_KEY_PATH')),
      in_house: false
    )
  end
  private_class_method :configure_asc!
end
