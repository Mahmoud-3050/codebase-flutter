# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require 'tmpdir'

module UI
  class << self
    def user_error!(message)
      raise message.to_s
    end

    def message(_message); end

    def important(_message); end

    def success(_message); end
  end
end

require_relative '../fastlane/shared/load_deploy_config'
require_relative '../fastlane/shared/flutter_build'
require_relative '../fastlane/shared/flutter_version'
require_relative '../fastlane/shared/android_signing'
require_relative '../fastlane/shared/pre_build'

module ReleaseTestHelper
  def with_env(values)
    previous = {}
    values.each do |key, value|
      previous[key] = ENV.key?(key) ? ENV[key] : :__unset__
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
    yield
  ensure
    previous.each do |key, value|
      if value == :__unset__
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
  end
end
