require "time"

class Pnmx::Tags
  attr_reader :config, :tags

  class << self
    def from_config(config, **extra)
      new(**default_tags(config), **extra)
    end

    def default_tags(config)
      { recorded_at: Time.now.utc.iso8601,
        performer: `whoami`.chomp,
        destination: config.destination,
        version: config.version,
        service_version: service_version(config) }
    end

    def service_version(config)
      [ config.service, config.abbreviated_version ].compact.join("@")
    end
  end

  def initialize(**tags)
    @tags = tags.compact
  end

  def env
    tags.transform_keys { |detail| "MRSK_#{detail.upcase}" }
  end

  def to_s
    tags.values.map { |value| "[#{value}]" }.join(" ")
  end

  def except(*tags)
    self.class.new(**self.tags.except(*tags))
  end
end
