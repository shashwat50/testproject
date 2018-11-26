
require 'ipaddr'
require 'socket'
require 'optparse'
require_relative 'incapsula_client'
require_relative 'incapsula_data'

DEFAULT_IP_GROUP_SIZE = 50

class WhitelistControl

  def initialize(options)
    @client = IncapsulaClient.new(
        ENV["API_ID"],
        ENV["API_KEY"],
        options[:verbose]
    )
  end

  def command_addset(options)
    group_size = options[:group_size] || DEFAULT_IP_GROUP_SIZE

    ips = read_input_ips

    puts "Requested new entries: #{ips.length}"

    options[:sites].each do |site_domain|
      puts "Processing site #{site_domain}"

      site = get_site site_domain
      ex = list_blacklist_exception_rules site

      existing_cidrs = ex.collect { |e| e.cidrs }.flatten.sort.uniq
      existing_ips = ex.collect { |e| e.ips }.flatten.sort.uniq
      filtered_ips = remove_redundant_ip_entries ips, existing_ips, existing_cidrs

      if filtered_ips.empty?
        puts "All requested entries are existing or redundant. Skipping site."
      else
        puts "Resolved new unique entries: #{filtered_ips.length}"

        grouped_ips = filtered_ips.each_slice(group_size)

        grouped_ips.each do |gip|
          puts "Adding whitelist group: #{gip.join(",")}"

          @client.add_whitelist(
            site.id,
            RULE_TYPE[:blacklisted_ips],
            gip
          )
        end
      end
    end
  end

  def command_deleteall(options)
    options[:sites].each do |site_domain|
      site = get_site site_domain
      whitelist_ids = list_whitelist_ids(site)

      whitelist_ids.each do |wid|
        puts "Deleting whitelist: site_id=#{site.id}, whitelist_id=#{wid}"
        @client.delete_whitelist(
          site.id,
          RULE_TYPE[:blacklisted_ips],
          wid
        )
      end
    end
  end

  def command_list(options)
    ex = []

    options[:sites].each do |site_domain|
      site = get_site site_domain
      be = list_blacklist_exception_rules site
      ex += be
    end

    if options[:resolve_redundancies]
      ip_entries = ex.collect { |e| e.ip_entries }.flatten.sort.uniq
      redundancies = ip_entry_redundancies ex
      resolved = ip_entries - redundancies
      puts resolved

    elsif options[:print_redundancies]
      redundancies = ip_entry_redundancies ex
      puts redundancies

    else
      ip_entries = ex.collect { |e| e.ip_entries }.flatten.sort.uniq
      puts ip_entries
    end
  end

  def read_input_ips
    ips = STDIN.read
    ips.lines.map { |l| l.strip }
  end

  def get_site site_domain
    sites = IncapsulaSiteListing.new(@client.list)
    sites.site_for_domain site_domain
  end

  def list_blacklist_exception_rules(site)
    rules = site.security_acl_rules_of_type RULE_TYPE[:blacklisted_ips]
    ble = rules.collect { |r| r.exceptions_of_type RULE_EXCEPTION_TYPE[:client_ip] }.flatten
    ble
  end

  def ip_entry_redundant?(ip, cidrs)
    return true if cidrs.include? ip

    cidrs.each do |cidr|
      begin
        addr = IPAddr.new cidr
      rescue IPAddr::InvalidAddressError => e
        STDERR.puts "Failed to parse '#{cidr}'"
        raise e
      end

      begin
        return true if addr.include? ip
      rescue IPAddr::InvalidAddressError => e
        STDERR.puts "Failed to parse '#{ip}'"
        raise e
      end
    end
    false
  end

  def remove_redundant_ip_entries(ips, existing_ips, existing_cidrs)
    rips = list_redundant_ip_entries ips, existing_cidrs
    ips - rips - existing_ips
  end

  def list_redundant_ip_entries(ips, cidrs)
    r = []
    ips.each do |ip|
      r << ip if ip_entry_redundant? ip, cidrs
    end
    r
  end

  def ip_entry_redundancies(ex)
    ips = ex.collect { |e| e.ips }.flatten.sort.uniq
    cidrs = ex.collect { |e| e.cidrs }.flatten.sort.uniq

    list_redundant_ip_entries ips, cidrs
  end

  def list_whitelist_ids(site_domain)
    ex = list_blacklist_exception_rules(site_domain)
    ids = ex.collect { |e| e.id }
    ids
  end

end
