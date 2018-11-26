
require 'net/http'
require 'uri'
require 'rubygems'
require 'json'

class IncapsulaClient

  BASE_URL = "https://my.incapsula.com"

  def initialize(api_id, api_key, verbose)
    @api_id = api_id
    @api_key = api_key
    @verbose = verbose
  end

  def vputs(msg)
    if @verbose
      puts msg
    end
  end

  def do_post(path, params)
    # TODO: This string URL building is horse shit

    params = (params || {}).clone
    params["api_id"] = @api_id
    params["api_key"] = @api_key

    s_uri = "#{BASE_URL}#{path}"
    uri = URI.parse(s_uri)
    full_uri = "#{uri}?#{URI.encode_www_form params}"

    vputs "POST #{full_uri}"

    response = Net::HTTP.post_form(uri, params || {})

    if response.code != "200"
      raise "Request to '#{full_uri}' failed: (#{response.code}) #{response.body}"
    end

    vputs "Response: #{response.body}"

    json_result = JSON.parse response.body

    if json_result["res"] != 0
      raise "Request to '#{full_uri}' failed: (#{response.code}) #{response.body}"
    end

    json_result
  end

  def list
    do_post "/api/prov/v1/sites/list", nil
  end

  def delete_whitelist(site_id, rule_id, whitelist_id)
    do_post "/api/prov/v1/sites/configure/whitelists", {
      "site_id" => site_id,
      "rule_id" => rule_id,
      "whitelist_id" => whitelist_id,
      "delete_whitelist" => true
    }
  end

  def add_whitelist(site_id, rule_id, ips)
    if ips.kind_of? Array
      ips = ips.join(",")
    end

    do_post "/api/prov/v1/sites/configure/whitelists", {
      "site_id" => site_id,
      "rule_id" => rule_id,
      "ips" => ips
    }
  end
end
