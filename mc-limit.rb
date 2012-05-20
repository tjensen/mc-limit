require 'date'
require 'yaml'
require 'dl'
require 'sys/proctable'
require_relative 'winfns'

module MCLimit
  # The default number of minutes of game play to allow per day
  DEFAULT_MINUTES = Float(ENV['DEFAULT_MC_LIMIT'] || 30)

  # The minimum number of remaining minutes needed to start the game
  MINIMUM_MINUTES = 1

  REMAINING_FILE = File.join( ENV['APPDATA'], 'mc-limit.yml' )

  COMMAND = 'javaw.exe -Xms512m -Xmx1024m -cp "%APPDATA%\.minecraft\bin\*" -Djava.library.path="%APPDATA%\.minecraft\bin\natives" net.minecraft.client.Minecraft'

  def self.disappoint( title, body )
    Win.message_box( title, body )
    exit 1
  end

  def self.remaining_minutes
    yaml = YAML.load_file( REMAINING_FILE )
    ( yaml[:date] == Date.today ) ? yaml[:remaining] : DEFAULT_MINUTES
  rescue
    DEFAULT_MINUTES
  end

  def self.update_remaining_minutes( minutes )
    yaml = { :date => Date.today, :remaining => minutes }.to_yaml
    File.write( REMAINING_FILE, yaml )
  end

  def self.timeout_pid(pid, minutes)
    Thread.new do
      sleep minutes * 60
      pids = [ pid ]
      Sys::ProcTable.ps do |process|
        pids << process.pid if pids.include? process.ppid
      end
      Win.close_process(pids, 'Minecraft')
    end
    pid
  end

  def self.validate_sufficient( time_limit )
    return if time_limit >= MINIMUM_MINUTES
    disappoint( 'Sorry', 'No more Minecraft allowed today!' )
  end

  def self.run( command, time_limit )
    validate_sufficient time_limit
    pid = timeout_pid( Process.spawn( command ), time_limit )
  end
end

if $0 == __FILE__
  remaining = MCLimit.remaining_minutes
  pid = MCLimit.run( MCLimit::COMMAND, remaining )

  start = Time.now
  Process.waitpid( pid, 0 )
  finish = Time.now

  consumed = ( finish - start ) / 60
  remaining = [ 0, remaining - consumed ].sort.last
  MCLimit.update_remaining_minutes( remaining )
end

# vim:ts=2:sw=2:et
