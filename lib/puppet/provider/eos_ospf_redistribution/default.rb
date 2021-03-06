#
# Copyright (c) 2014, Arista Networks, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#   Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
#   Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
#   Neither the name of Arista Networks nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
require 'puppet/type'
require 'pathname'

module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
require File.join module_lib, 'puppet_x/eos/provider'

Puppet::Type.type(:eos_ospf_redistribution).provide(:eos) do
  desc 'Manage OSPF redistributions on EOS. Requires rbeapi rubygem.'
  confine operatingsystem: [:AristaEOS] unless ENV['RBEAPI_CONNECTION']
  confine feature: :rbeapi

  # Create methods that set the @property_hash for the #flush method
  mk_resource_methods

  # Mix in the api as instance methods
  include PuppetX::Eos::EapiProviderMixin

  # Mix in the api as class methods
  extend PuppetX::Eos::EapiProviderMixin

  def self.instances
    ospf = node.api('ospf').getall
    return [] if !ospf || ospf.nil?
    arr = []
    ospf.each do |(instance_id, attrs)|
      next if name.eql? 'interfaces'
      redistribute = attrs[:redistribute]
      next if redistribute.nil?
      redistribute.each do |(protocol, routemap)|
        provider_hash = { name: protocol, ensure: :present }
        provider_hash[:instance_id] = instance_id.to_i
        provider_hash[:route_map] = routemap[:route_map]
        arr.push(new(provider_hash))
      end
    end
    arr
  end

  def initialize(resource = {})
    super(resource)
    @property_flush = {}
  end

  def route_map=(val)
    @property_flush[:route_map] = val
  end

  def instance_id=(val)
    @property_flush[:instance_id] = val
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    fail('instance_id property must be included') \
      if resource[:instance_id].nil?
    @property_flush = resource.to_hash
  end

  def destroy
    fail('instance_id property must be included') \
      if resource[:instance_id].nil?
    @property_flush = resource.to_hash
  end

  def flush
    desired_state = @property_hash.merge!(@property_flush)
    case desired_state[:ensure]
    when :present
      node.api('ospf').set_redistribute(desired_state[:instance_id],
                                        desired_state[:name],
                                        route_map: desired_state[:route_map])
    when :absent
      node.api('ospf').set_redistribute(desired_state[:instance_id],
                                        desired_state[:name],
                                        route_map: desired_state[:route_map],
                                        enable: false)
    end
    @property_hash = desired_state
  end
end
