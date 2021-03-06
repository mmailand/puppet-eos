#
# Copyright (c) 2014, Arista Networks, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#  Redistributions of source code must retain the above copyright notice,
#  this list of conditions and the following disclaimer.
#
#  Redistributions in binary form must reproduce the above copyright
#  notice, this list of conditions and the following disclaimer in the
#  documentation and/or other materials provided with the distribution.
#
#  Neither the name of Arista Networks nor the names of its
#  contributors may be used to endorse or promote products derived from
#  this software without specific prior written permission.
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
# encoding: utf-8

require 'spec_helper'

describe Puppet::Type.type(:eos_portchannel) do
  let(:catalog) { Puppet::Resource::Catalog.new }
  let(:type) { described_class.new(name: 'Port-Channel100', catalog: catalog) }

  it_behaves_like 'an ensurable type', name: 'Port-Channel100'

  describe 'name' do
    let(:attribute) { :name }
    subject { described_class.attrclass(attribute) }

    include_examples 'parameter'
    include_examples '#doc Documentation'
  end

  describe 'lacp_mode' do
    let(:attribute) { :lacp_mode }
    subject { described_class.attrclass(attribute) }

    include_examples 'property'
    include_examples '#doc Documentation'
    include_examples 'accepts values', [:active, :passive, :on]
    include_examples 'rejected parameter values'
  end

  describe 'members' do
    let(:attribute) { :members }
    subject { described_class.attrclass(attribute) }

    include_examples 'property'
    include_examples '#doc Documentation'
    include_examples 'accepts values without munging', [['Ethernet1']]
    include_examples 'rejects values', [0, [1], { two: :three }, 'foo']
  end

  describe 'minimum_links' do
    let(:attribute) { :minimum_links }
    subject { described_class.attrclass(attribute) }

    include_examples 'property'
    include_examples '#doc Documentation'
    include_examples 'accepts values without munging', [0, 16]
    include_examples 'rejects values', [[-1], 'string', { two: :three }, 17]
  end

  describe 'lacp_fallback' do
    let(:attribute) { :lacp_fallback }
    subject { described_class.attrclass(attribute) }

    include_examples 'property'
    include_examples '#doc Documentation'
    include_examples 'accepts values', [:static, :individual]
    include_examples 'rejected parameter values'
  end

  describe 'lacp_timeout' do
    let(:attribute) { :lacp_timeout }
    subject { described_class.attrclass(attribute) }

    include_examples 'property'
    include_examples '#doc Documentation'
    include_examples 'accepts values without munging', [1, 900]
    include_examples 'rejects values', ['string', { two: :three }]
  end
end
