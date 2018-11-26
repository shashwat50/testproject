
require 'rubygems'
require 'json'

RULE_TYPE = {
    :blacklisted_ips => "api.acl.blacklisted_ips"
}

RULE_EXCEPTION_TYPE = {
    :client_ip => "api.rule_exception_type.client_ip"
}

class IncapsulaDataUtil

  IP_BLOCK = /\d{,2}|1\d{2}|2[0-4]\d|25[0-5]/
  IP_RE = /\A#{IP_BLOCK}\.#{IP_BLOCK}\.#{IP_BLOCK}\.#{IP_BLOCK}\z/
  CIDR_RE = /\A#{IP_BLOCK}\.#{IP_BLOCK}\.#{IP_BLOCK}\.#{IP_BLOCK}\/\d{1,2}\z/
  IP_RANGE_RE = /\A#{IP_BLOCK}\.#{IP_BLOCK}\.#{IP_BLOCK}\.#{IP_BLOCK}[-]#{IP_BLOCK}\.#{IP_BLOCK}\.#{IP_BLOCK}\.#{IP_BLOCK}\z/

  def self.ip?(test)
    !(IP_RE =~ test).nil?
  end

  def self.cidr?(test)
    !(CIDR_RE =~ test).nil?
  end

  def self.ip_range?(test)
    !(IP_RANGE_RE =~ test).nil?
  end
end

class IncapsulaBaseType

  def initialize(data)
    @data = data
  end

  def data
    @data
  end

  def to_s
    JSON.pretty_generate @data
  end

end

class IncapsulaSiteListing < IncapsulaBaseType

  def site_for_domain(domain)
    match = @data["sites"].select { |s| s["domain"] == domain }
    match and IncapsulaSite.new(match[0]) or nil
  end

end

class IncapsulaSite < IncapsulaBaseType

  def id
    @data["site_id"]
  end

  def security_acl_rules
    result = (@data["security"]["acls"] || {})["rules"]
    if result
      result.map { |r| IncapsulaACLRule.new r }
    end
  end

  def security_acl_rules_of_type(type)
    security_acl_rules.select { |r| r.id == type }
  end

end


class IncapsulaACLRule < IncapsulaBaseType

  def id
    @data["id"]
  end

  def ips
    @data["ips"]
  end

  def exceptions
    (@data["exceptions"] || []).map { |e| IncapsulaException.new e }
  end

  def exceptions_of_type(type)
    exceptions.select { |e| e.has_type? type }
  end

end

class IncapsulaException < IncapsulaBaseType

  def id
    @data["id"]
  end

  def values
    @data["values"]
  end

  def values_of_type(type)
    values.select { |v| v["id"] == type }
  end

  def has_type?(type)
    !values_of_type(type).empty?
  end

  # ips, ranges, and cidrs alike
  def ip_entries
    values_of_type(RULE_EXCEPTION_TYPE[:client_ip])
        .collect { |v| v["ips"] }
        .flatten
        .map { |e| e.strip }
  end

  def ips
    ip_entries.select { |e| IncapsulaDataUtil.ip? e }
  end

  def ip_ranges
    ip_entries.select { |e| IncapsulaDataUtil.ip_range? e }
  end

  def cidrs
    ip_entries.select { |e| IncapsulaDataUtil.cidr? e }
  end

end
