require 'aws-sdk-ec2'
require 'aws-sdk-route53'


module VagrantPlugins
  module AwsDns
    module Util
      class AwsUtil

        attr_reader :ec2, :route53, :logger

        def initialize(accesskey, secretkey, session_token, region, route53_accesskey, route53_secretkey, route53_session_token, route53_region)

          @logger = Log4r::Logger.new("vagrant::plugins::vagrant-aws-dns::action::util")

          credentials = nil

          if session_token.nil? || session_token.length.zero?
            credentials = Aws::Credentials.new(accesskey, secretkey)
          else
            credentials = Aws::Credentials.new(accesskey, secretkey, session_token)
          end

          @ec2 = Aws::EC2::Client.new(
              region: region,
              credentials: credentials
          )

          if route53_session_token.nil? || route53_session_token.length.zero?
            credentials = Aws::Credentials.new(route53_accesskey, route53_secretkey)
          else
            credentials = Aws::Credentials.new(route53_accesskey, route53_secretkey, route53_session_token)
          end

          @route53 = Aws::Route53::Client.new(
              region: route53_region,
              credentials: credentials
          )
        end

        def get_public_ip(instance_id)
          begin
            @ec2.describe_instances({instance_ids: [instance_id]}).reservations[0].instances[0].public_ip_address
          rescue RuntimeError => e
            @logger.error e.message
          end
        end

        def get_private_ip(instance_id)
          begin
            @ec2.describe_instances({instance_ids: [instance_id]}).reservations[0].instances[0].private_ip_address
          rescue RuntimeError => e
            @logger.error e.message
          end
        end

        def is_private_zone(hosted_zone_id)
          begin
            @route53.get_hosted_zone({id: '/hostedzone/' + hosted_zone_id}).hosted_zone.config.private_zone
          rescue RuntimeError => e
            @logger.error e.message
          end
        end

        def add_record(hosted_zone_id, record, type, value)
          change_record(hosted_zone_id, record, type, value, 'UPSERT')
        end

        def remove_record(hosted_zone_id, record, type, value)
          change_record(hosted_zone_id, record, type, value, 'DELETE')
        end

        private

        def change_record(hosted_zone_id, record, type, value, action='CREATE')
          begin
            @route53.change_resource_record_sets({
              hosted_zone_id: hosted_zone_id, # required
                change_batch: {
                  changes: [
                    {
                      action: action, # required, accepts CREATE, DELETE, UPSERT
                      resource_record_set: {
                        name: record, # required
                        type: type, # required, accepts SOA, A, TXT, NS, CNAME, MX, PTR, SRV, SPF, AAAA
                        ttl: 1,
                        resource_records: [
                          {
                            value: value # required
                          }
                        ]
                      }
                    }
                  ]
                }
            })
          rescue RuntimeError => e
            @logger.error e.message
          end
        end
      end
    end
  end
end
