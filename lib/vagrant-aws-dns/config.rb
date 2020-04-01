require 'vagrant'


module VagrantPlugins
  module AwsDns
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :hosted_zone_id
      attr_accessor :record_sets
      attr_accessor :access_key_id
      attr_accessor :secret_access_key
      attr_accessor :session_token
      attr_accessor :private_zone
      attr_accessor :region

      def initialize
        @hosted_zone_id = UNSET_VALUE
        @record_sets = UNSET_VALUE
        @access_key_id = UNSET_VALUE
        @secret_access_key = UNSET_VALUE
        @session_token = UNSET_VALUE
        @private_zone = UNSET_VALUE
        @region = UNSET_VALUE
      end

      def finalize!
        @hosted_zone_id = nil if @hosted_zone_id == UNSET_VALUE
        @record_sets = nil if @record_sets == UNSET_VALUE
        @access_key_id = nil if @access_key_id == UNSET_VALUE
        @secret_access_key = nil if @secret_access_key == UNSET_VALUE
        @session_token = nil if @session_token == UNSET_VALUE
        @private_zone = nil if @private_zone == UNSET_VALUE
        @region = nil if @region == UNSET_VALUE
      end

      def validate(machine)
        finalize!

        errors = _detected_errors

        { 'AwsDns' => errors }
      end
    end
  end
end