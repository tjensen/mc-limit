require 'date'
require 'yaml'
require 'sys/proctable'

module MCLimit
  # The default number of minutes of game play to allow per day when env not set
  DEFAULT_MINUTES = 30

  # The minimum number of remaining minutes needed to start the game
  MINIMUM_MINUTES = 1

  REMAINING_FILE = File.join( ENV['APPDATA'], 'mc-limit.yml' )

  COMMAND = 'javaw.exe -Xms512m -Xmx1024m -cp "%APPDATA%\.minecraft\bin\*" -Djava.library.path="%APPDATA%\.minecraft\bin\natives" net.minecraft.client.Minecraft'

  def self.disappoint( title, body )
    GUI.error( body, title )
    exit 1
  end

  def self.default_minutes
    Float( ENV['DEFAULT_MC_LIMIT'] || DEFAULT_MINUTES )
  end

  def self.admin_password
    ENV['MC_LIMIT_ADMIN_PASSWORD']
  end

  def self.remaining_minutes( date = Date.today )
    yaml = YAML.load_file( REMAINING_FILE )
    ( yaml[:date] == date ) ? Float(yaml[:remaining]) : default_minutes
  rescue
    default_minutes
  end

  def self.update_remaining_minutes( minutes )
    yaml = { :date => Date.today, :remaining => minutes }.to_yaml
    File.open( REMAINING_FILE, 'wt' ) { |f| f.write yaml }
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

  def self.launch
    GUI.new.main_loop do
      remaining = MCLimit.remaining_minutes
      pid = MCLimit.run( MCLimit::COMMAND, remaining )

      start = Time.now
      Process.waitpid( pid, 0 )
      finish = Time.now

      consumed = ( finish - start ) / 60
      remaining = [ 0, remaining - consumed ].sort.last
      MCLimit.update_remaining_minutes( remaining )
    end
  end
end

# vim:ts=2:sw=2:et
