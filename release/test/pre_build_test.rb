# frozen_string_literal: true

require_relative 'test_helper'

class PreBuildTest < Minitest::Test
  include ReleaseTestHelper

  def teardown
    %w[
      PRE_BUILD_SCRIPT ANDROID_PRE_BUILD_SCRIPT IOS_PRE_BUILD_SCRIPT
      GOOGLE_PLAY_TRACK
    ].each { |key| ENV.delete(key) }
  end

  def test_script_order_shared_then_platform
    with_env(
      'PRE_BUILD_SCRIPT' => 'hooks/shared.sh',
      'ANDROID_PRE_BUILD_SCRIPT' => 'hooks/android.sh',
      'IOS_PRE_BUILD_SCRIPT' => 'hooks/ios.sh'
    ) do
      assert_equal(
        ['hooks/shared.sh', 'hooks/android.sh'],
        PreBuild.send(:scripts_for, 'android')
      )
      assert_equal(
        ['hooks/shared.sh', 'hooks/ios.sh'],
        PreBuild.send(:scripts_for, 'ios')
      )
    end
  end

  def test_empty_scripts_are_skipped
    with_env(
      'PRE_BUILD_SCRIPT' => '',
      'ANDROID_PRE_BUILD_SCRIPT' => '',
      'IOS_PRE_BUILD_SCRIPT' => 'hooks/ios.sh'
    ) do
      assert_empty(PreBuild.send(:scripts_for, 'android'))
      assert_equal(['hooks/ios.sh'], PreBuild.send(:scripts_for, 'ios'))
    end
  end

  def test_missing_script_raises
    with_env(
      'GOOGLE_PLAY_TRACK' => 'internal',
      'PRE_BUILD_SCRIPT' => 'does-not-exist.sh'
    ) do
      error = assert_raises(RuntimeError) do
        PreBuild.run!(Object.new, platform: 'android')
      end
      assert_match(/Pre-build script not found/, error.message)
    end
  end
end
