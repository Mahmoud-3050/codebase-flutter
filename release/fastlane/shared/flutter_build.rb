# frozen_string_literal: true

require 'shellwords'

# Resolves Flutter build arguments and artifact paths for flavored and
# non-flavored projects. All flavor branching lives here so lanes stay identical.
module FlutterBuild
  UI = defined?(FastlaneCore::UI) ? FastlaneCore::UI : ::UI

  # `bundle exec fastlane` injects RUBYOPT=bundler/setup (and often GEM_HOME)
  # into child processes. Flutter then shells out to Homebrew `pod`, which is
  # a Ruby executable Bundler intercepts ("cocoapods is not in the Gemfile")
  # or that fails to load its own gems. Strip Bundler for Flutter only.
  def self.with_unbundled_env
    return yield unless defined?(Bundler)

    if Bundler.respond_to?(:with_unbundled_env)
      Bundler.with_unbundled_env { yield }
    elsif Bundler.respond_to?(:with_clean_env)
      Bundler.with_clean_env { yield }
    else
      yield
    end
  end

  def self.run_flutter!(lane, *args)
    with_unbundled_env do
      Dir.chdir(DeployConfig::ROOT) do
        lane.sh(Shellwords.join(['flutter', *args.flatten]))
      end
    end
  end

  def self.android_flutter_args
    [
      'build', 'appbundle', '--release',
      '--obfuscate', '--split-debug-info=build/app/symbols',
      *build_arg_list
    ]
  end

  def self.ios_flutter_args
    [
      'build', 'ipa', '--release',
      '--obfuscate', '--split-debug-info=build/ios/symbols',
      *build_arg_list
    ]
  end

  def self.skip_compile?(path)
    DeployConfig.truthy?('SKIP_BUILD_IF_EXISTS') && File.file?(path)
  end

  def self.aab_abs_path
    DeployConfig.project_path(aab_path)
  end

  def self.ipa_dir
    DeployConfig.project_path('build', 'ios', 'ipa')
  end

  def self.legacy_ipa_path
    File.join(DeployConfig::RELEASE_DIR, 'Runner.ipa')
  end

  def self.newest_ipa_in(dir)
    Dir.glob(File.join(dir, '*.ipa')).select { |path| File.file?(path) }.max_by { |path| File.mtime(path) }
  end

  def self.existing_ipa_path
    newest_ipa_in(ipa_dir) || (File.file?(legacy_ipa_path) ? legacy_ipa_path : nil)
  end

  def self.ipa_abs_path
    existing_ipa_path || File.join(ipa_dir, 'Runner.ipa')
  end

  # Flutter 3.44 regenerates iOS/macOS Swift Package Manager plugin links for
  # every `flutter build`, including Android. A leftover
  # `*/Flutter/ephemeral/Packages/.packages` directory makes Dart's
  # `deleteSync` fail with ENOTEMPTY (errno 66) and abort the tool.
  def self.clean_darwin_ephemeral!
    %w[ios macos].each do |platform|
      path = DeployConfig.project_path(platform, 'Flutter', 'ephemeral')
      next unless File.exist?(path)

      UI.message("Removing leftover #{platform}/Flutter/ephemeral")
      system('rm', '-rf', path)
      UI.user_error!("Could not remove #{path}. Close Xcode/Finder and retry.") if File.exist?(path)
    end
  end

  def self.flavored?
    DeployConfig.truthy?('USES_FLAVORS')
  end

  def self.flavor
    return nil unless flavored?

    name = ENV.fetch('FLAVOR', '').strip
    UI.user_error!('FLAVOR is required when USES_FLAVORS=true') if name.empty?
    name
  end

  def self.entrypoint
    ENV.fetch('ENTRYPOINT', 'lib/main.dart')
  end

  def self.build_arg_list
    args = []
    flavor_name = flavor
    args += ['--flavor', flavor_name] if flavor_name
    args += ['-t', entrypoint]
    args
  end

  def self.aab_path
    return 'build/app/outputs/bundle/release/app-release.aab' unless flavored?

    name = flavor
    "build/app/outputs/bundle/#{name}Release/app-#{name}-release.aab"
  end

  def self.ios_scheme
    value = ENV['IOS_SCHEME'].to_s.strip
    value.empty? ? 'Runner' : value
  end

  def self.ios_configuration
    value = ENV['IOS_CONFIGURATION'].to_s.strip
    value.empty? ? 'Release' : value
  end
end
