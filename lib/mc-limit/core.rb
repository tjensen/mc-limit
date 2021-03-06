require 'date'
require 'yaml'
require 'fileutils'
require 'sys/proctable'

module MCLimit
  # The default number of minutes of game play to allow per day when env not set
  DEFAULT_MINUTES = 30

  # The minimum number of remaining minutes needed to start the game
  MINIMUM_MINUTES = 1

  REMAINING_FILE = 'remaining.yml'

  GAME_COMMAND = %{javaw.exe -Xms512m -Xmx1024m -cp "%APPDATA%\\.minecraft\\bin\\*" -Djava.library.path="%APPDATA%\\.minecraft\\bin\\natives" net.minecraft.client.Minecraft "#{Etc.getlogin}"}

  def self.disappoint( title, body )
    GUI.error( body, title )
    exit 1
  end

  def self.game_command
    ENV['MC_LIMIT_COMMAND'] || GAME_COMMAND
  end

  def self.remaining_file
    if ENV['MC_LIMIT_FILE'].nil?
      if RUBY_PLATFORM =~ /mingw/
        File.join( ENV['APPDATA'], '.mc-limit', REMAINING_FILE )
      else
        File.join( ENV['HOME'], '.mc-limit', REMAINING_FILE )
      end
    else
      ENV['MC_LIMIT_FILE']
    end
  end

  def self.admin_password
    ENV['MC_LIMIT_ADMIN_PASSWORD']
  end

  def self.default_minutes
    Float( ENV['DEFAULT_MC_LIMIT'] || DEFAULT_MINUTES )
  end

  def self.remaining_minutes( date = Date.today )
    FileUtils.mkdir_p( File.dirname( MCLimit.remaining_file ) )
    yaml = YAML.load_file( MCLimit.remaining_file )
    ( yaml[:date] == date ) ? Float(yaml[:remaining]) : default_minutes
  rescue
    default_minutes
  end

  def self.update_remaining_minutes( minutes )
    yaml = { :date => Date.today, :remaining => minutes }.to_yaml
    FileUtils.mkdir_p( File.dirname( MCLimit.remaining_file ) )
    File.open( MCLimit.remaining_file, 'wt' ) { |f| f.write yaml }
  end

  def self.stop_minecraft(pids)
    if RUBY_PLATFORM =~ /mingw/
      Win.close_process(pids, 'Minecraft')
    else
      pids.each { |pid| kill(:QUIT, pid) }
    end
  end

  def self.timeout_pid(pid, minutes)
    Thread.new do
      sleep minutes * 60
      pids = [ pid ]
      Sys::ProcTable.ps do |process|
        pids << process.pid if pids.include? process.ppid
      end
      MCLimit.stop_minecraft(pids)
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
      pid = MCLimit.run( MCLimit.game_command, remaining )

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
