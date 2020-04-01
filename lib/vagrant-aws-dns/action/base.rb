require 'aws-sdk-core'
require_relative '../util/aws_util'


module VagrantPlugins
  module AwsDns
    module Action
      class Base

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
        end

        def call(env)
          return @app.call(env) if @machine.config.dns.record_sets.nil?

          access_key_id = @machine.provider_config.access_key_id
          secret_access_key = @machine.provider_config.secret_access_key
          session_token = @machine.provider_config.session_token
          region = @machine.provider_config.region

          private_zone = !@machine.config.dns.private_zone.nil?

          if @machine.config.dns.access_key_id.nil?
            route53_access_key_id = access_key_id
            route53_secret_access_key = secret_access_key
            route53_session_token = session_token
            route53_region = region
          else
            route53_access_key_id = @machine.config.dns.access_key_id
            route53_secret_access_key = @machine.config.dns.secret_access_key
            route53_session_token = @machine.config.dns.session_token
            route53_region = @machine.config.dns.region
          end

          @aws = AwsDns::Util::AwsUtil.new(
            access_key_id, secret_access_key, session_token, region,
            route53_access_key_id, route53_secret_access_key, route53_session_token, route53_region
          )

          public_ip = @aws.get_public_ip(@machine.id)
          private_ip = @aws.get_private_ip(@machine.id)

          @machine.config.dns.record_sets.each do |record_set|
            hosted_zone_id, record, type, value = record_set

            if private_zone
              yield hosted_zone_id, record, type, value || private_ip  if block_given?
            elsif @aws.is_private_zone(hosted_zone_id)
              yield hosted_zone_id, record, type, value || private_ip  if block_given?
            else
              yield hosted_zone_id, record, type, value || public_ip  if block_given?
            end
          end

          @app.call(env)
        end

      end
    end
  end
end
