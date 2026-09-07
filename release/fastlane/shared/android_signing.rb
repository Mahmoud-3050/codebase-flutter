# frozen_string_literal: true

# Writes android/key.properties from deploy.config so Gradle signing and
# the deploy file stay a single source of truth.
module AndroidSigning
  UI = defined?(FastlaneCore::UI) ? FastlaneCore::UI : ::UI

  def self.write_key_properties!
    keystore = DeployConfig.secret_path(ENV.fetch('ANDROID_KEYSTORE_PATH'))
    UI.user_error!("Keystore not found: #{keystore}") unless File.exist?(keystore)

    properties = <<~PROPS
      storePassword=#{escape(ENV.fetch('ANDROID_KEYSTORE_PASSWORD'))}
      keyPassword=#{escape(ENV.fetch('ANDROID_KEY_PASSWORD'))}
      keyAlias=#{escape(ENV.fetch('ANDROID_KEY_ALIAS'))}
      storeFile=#{keystore}
    PROPS

    path = DeployConfig.project_path('android', 'key.properties')
    File.write(path, properties)
    File.chmod(0o600, path)
    UI.message("Wrote #{path}")
  end

  def self.escape(value)
    value.to_s.gsub('\\') { '\\\\' }.gsub(/[=:]/) { |char| "\\#{char}" }
  end
  private_class_method :escape
end
