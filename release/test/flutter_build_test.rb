# frozen_string_literal: true

require_relative 'test_helper'

class FlutterBuildTest < Minitest::Test
  include ReleaseTestHelper

  def teardown
    %w[
      USES_FLAVORS FLAVOR ENTRYPOINT IOS_SCHEME IOS_CONFIGURATION
      SKIP_BUILD_IF_EXISTS
    ].each { |key| ENV.delete(key) }
  end

  def test_flavored_build_args_and_aab_path
    with_env(
      'USES_FLAVORS' => 'true',
      'FLAVOR' => 'live',
      'ENTRYPOINT' => 'lib/main_live.dart'
    ) do
      assert_equal(
        ['--flavor', 'live', '-t', 'lib/main_live.dart'],
        FlutterBuild.build_arg_list
      )
      assert_equal(
        'build/app/outputs/bundle/liveRelease/app-live-release.aab',
        FlutterBuild.aab_path
      )
    end
  end

  def test_flavored_dev_aab_path
    with_env('USES_FLAVORS' => 'true', 'FLAVOR' => 'dev', 'ENTRYPOINT' => 'lib/main_dev.dart') do
      assert_equal(
        'build/app/outputs/bundle/devRelease/app-dev-release.aab',
        FlutterBuild.aab_path
      )
    end
  end

  def test_non_flavored_build_args_and_aab_path
    with_env(
      'USES_FLAVORS' => 'false',
      'FLAVOR' => '',
      'ENTRYPOINT' => 'lib/main.dart'
    ) do
      assert_equal(['-t', 'lib/main.dart'], FlutterBuild.build_arg_list)
      assert_equal(
        'build/app/outputs/bundle/release/app-release.aab',
        FlutterBuild.aab_path
      )
    end
  end

  def test_flavored_without_flavor_raises
    with_env('USES_FLAVORS' => 'true', 'FLAVOR' => '') do
      error = assert_raises(RuntimeError) { FlutterBuild.build_arg_list }
      assert_match(/FLAVOR is required/, error.message)
    end
  end

  def test_ios_scheme_and_configuration_defaults
    with_env('IOS_SCHEME' => '', 'IOS_CONFIGURATION' => '') do
      assert_equal('Runner', FlutterBuild.ios_scheme)
      assert_equal('Release', FlutterBuild.ios_configuration)
    end
  end

  def test_ios_scheme_and_configuration_from_env
    with_env('IOS_SCHEME' => 'live', 'IOS_CONFIGURATION' => 'Release-live') do
      assert_equal('live', FlutterBuild.ios_scheme)
      assert_equal('Release-live', FlutterBuild.ios_configuration)
    end
  end

  def test_with_unbundled_env_yields
    called = false
    FlutterBuild.with_unbundled_env { called = true }
    assert called
  end

  def test_with_unbundled_env_strips_bundler_from_child_env
    skip unless defined?(Bundler) && Bundler.respond_to?(:with_unbundled_env)

    with_env(
      'GEM_HOME' => '/tmp/fake-fastlane-bundle',
      'GEM_PATH' => '/tmp/fake-fastlane-bundle',
      'RUBYOPT' => '-rbundler/setup'
    ) do
      FlutterBuild.with_unbundled_env do
        refute_equal '/tmp/fake-fastlane-bundle', ENV['GEM_HOME']
        refute_match(%r{bundler/setup}, ENV.fetch('RUBYOPT', ''))
      end
    end
  end

  def test_android_flutter_args_include_obfuscation
    with_env(
      'USES_FLAVORS' => 'false',
      'FLAVOR' => '',
      'ENTRYPOINT' => 'lib/main.dart'
    ) do
      assert_equal(
        [
          'build', 'appbundle', '--release',
          '--obfuscate', '--split-debug-info=build/app/symbols',
          '-t', 'lib/main.dart'
        ],
        FlutterBuild.android_flutter_args
      )
    end
  end

  def test_ios_flutter_args_include_obfuscation
    with_env(
      'USES_FLAVORS' => 'false',
      'FLAVOR' => '',
      'ENTRYPOINT' => 'lib/main.dart'
    ) do
      assert_equal(
        [
          'build', 'ipa', '--release',
          '--obfuscate', '--split-debug-info=build/ios/symbols',
          '-t', 'lib/main.dart'
        ],
        FlutterBuild.ios_flutter_args
      )
    end
  end

  def test_skip_compile_requires_flag_and_file
    Dir.mktmpdir do |dir|
      missing = File.join(dir, 'missing.aab')
      present = File.join(dir, 'app.aab')
      File.write(present, 'aab')

      with_env('SKIP_BUILD_IF_EXISTS' => 'false') do
        refute FlutterBuild.skip_compile?(present)
      end
      with_env('SKIP_BUILD_IF_EXISTS' => 'true') do
        refute FlutterBuild.skip_compile?(missing)
        assert FlutterBuild.skip_compile?(present)
      end
    end
  end

  def test_newest_ipa_in_picks_latest_file
    Dir.mktmpdir do |dir|
      older = File.join(dir, 'old.ipa')
      newer = File.join(dir, 'new.ipa')
      File.write(older, 'old')
      File.write(newer, 'new')
      File.utime(Time.now - 60, Time.now - 60, older)
      File.utime(Time.now, Time.now, newer)
      assert_equal newer, FlutterBuild.newest_ipa_in(dir)
    end
  end
end
