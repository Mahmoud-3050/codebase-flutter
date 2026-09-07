# frozen_string_literal: true

require 'shellwords'

# Runs optional hooks from deploy.config immediately before an AAB or IPA build.
# PRE_BUILD_SCRIPT runs for every platform. ANDROID_PRE_BUILD_SCRIPT /
# IOS_PRE_BUILD_SCRIPT run only for that platform. Empty values are skipped.
module PreBuild
  def self.run!(lane, platform:)
    track = ENV.fetch('GOOGLE_PLAY_TRACK')
    ENV['DEPLOY_TRACK'] = track
    ENV['DEPLOY_PLATFORM'] = platform

    scripts_for(platform).each do |relative|
      path = DeployConfig.hook_path(relative)
      unless File.file?(path)
        UI.user_error!("Pre-build script not found: #{relative} (resolved to #{path})")
      end

      UI.message("Running pre-build script (#{platform}): #{path}")
      Dir.chdir(DeployConfig::ROOT) do
        lane.sh(Shellwords.join(['bash', path, track, platform]))
      end
    end
  end

  def self.scripts_for(platform)
    shared = ENV.fetch('PRE_BUILD_SCRIPT', '').strip
    specific = ENV.fetch("#{platform.upcase}_PRE_BUILD_SCRIPT", '').strip
    [shared, specific].reject(&:empty?).uniq
  end
  private_class_method :scripts_for
end
