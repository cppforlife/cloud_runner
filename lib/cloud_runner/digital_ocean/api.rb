require "digital_ocean"
require "cloud_runner/digital_ocean/base"

module CloudRunner::DigitalOcean
  class Api
    def initialize(client_id, api_key)
      @client_id = client_id
      @api_key = api_key
    end

    def self.find(object_type, field)
      define_method("all_#{object_type}s") do
        method = "#{object_type}s"
        api.send(method).list.send(method)
      end

      define_method("find_#{object_type}_by_#{field}") do |value|
        send("all_#{object_type}s").detect do |object|
          object.send(field) == value
        end
      end
    end

    find :region, :name
    find :size,   :name
    find :image,  :name

    def self.delegate(method_name)
      define_method(method_name) { api.send(method_name) }
    end

    delegate :ssh_keys
    delegate :droplets

    private

    def api
      @api ||= ::DigitalOcean::API.new(
        :client_id => @client_id,
        :api_key => @api_key,
      )
    end
  end
end
