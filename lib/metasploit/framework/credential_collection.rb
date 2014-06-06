require 'metasploit/framework/credential'

class Metasploit::Framework::CredentialCollection

  # @!attribute blank_passwords
  #   Whether each username should be tried with a blank password
  #   @return [Boolean]
  attr_accessor :blank_passwords
  # @!attribute pass_file
  #   Path to a file containing passwords, one per line
  #   @return [String]
  attr_accessor :pass_file
  # @!attribute realm
  #   @return [String]
  attr_accessor :realm
  # @!attribute password
  #   @return [String]
  attr_accessor :password
  # @!attribute user_as_pass
  #   Whether each username should be tried as a password for that user
  #   @return [Boolean]
  attr_accessor :user_as_pass
  # @!attribute user_file
  #   Path to a file containing usernames, one per line
  #   @return [String]
  attr_accessor :user_file
  # @!attribute username
  #   @return [String]
  attr_accessor :username
  # @!attribute user_file
  #   Path to a file containing usernames and passwords seperated by a space,
  #   one pair per line
  #   @return [String]
  attr_accessor :userpass_file

  # @option opts [Boolean] :blank_passwords See {#blank_passwords}
  # @option opts [String] :pass_file See {#pass_file}
  # @option opts [String] :password See {#password}
  # @option opts [Boolean] :user_as_pass See {#user_as_pass}
  # @option opts [String] :user_file See {#user_file}
  # @option opts [String] :username See {#username}
  # @option opts [String] :userpass_file See {#userpass_file}
  def initialize(opts = {})
    opts.each do |attribute, value|
      public_send("#{attribute}=", value)
    end
  end

  # Combines all the provided credential sources into a stream of {Credential}
  # objects, yielding them one at a time
  #
  # @yieldparam credential [Metasploit::Framework::Credential]
  # @return [void]
  def each
    if pass_file
      pass_fd = File.open(pass_file, 'r:binary')
    end

    if username
      if password
        yield Metasploit::Framework::Credential.new(public: username, private: password, realm: realm)
      end
      if user_as_pass
        yield Metasploit::Framework::Credential.new(public: username, private: username, realm: realm)
      end
      if blank_passwords
        yield Metasploit::Framework::Credential.new(public: username, private: "", realm: realm)
      end
      if pass_fd
        pass_fd.each_line do |pass_from_file|
          pass_from_file.chomp!
          yield Metasploit::Framework::Credential.new(public: username, private: pass_from_file, realm: realm)
        end
        pass_fd.seek(0)
      end
    end

    if user_file
      File.open(user_file, 'r:binary') do |user_fd|
        user_fd.each_line do |user_from_file|
          user_from_file.chomp!
          if password
            yield Metasploit::Framework::Credential.new(public: user_from_file, private: password, realm: realm)
          end
          if user_as_pass
            yield Metasploit::Framework::Credential.new(public: user_from_file, private: user_from_file, realm: realm)
          end
          if blank_passwords
            yield Metasploit::Framework::Credential.new(public: user_from_file, private: "", realm: realm)
          end
          if pass_fd
            pass_fd.each_line do |pass_from_file|
              pass_from_file.chomp!
              yield Metasploit::Framework::Credential.new(public: user_from_file, private: pass_from_file, realm: realm)
            end
            pass_fd.seek(0)
          end
        end
      end
    end

    if userpass_file
      File.open(userpass_file, 'r:binary') do |userpass_fd|
        userpass_fd.each_line do |line|
          user, pass = line.split(" ", 2)
          pass.chomp!
          yield Metasploit::Framework::Credential.new(public: user, private: pass, realm: realm)
        end
      end
    end

  ensure
    pass_fd.close if pass_fd && !pass_fd.closed?
  end

end
