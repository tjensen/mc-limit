require 'date'
require 'yaml'
require 'dl'
require 'sys/proctable'

MINUTES = 30

MINIMUM_MINUTES = 1

REMAINING_FILE = File.join( ENV['APPDATA'], 'mc-limit.yml' )

JAVA = 'c:\Program Files (x86)\Java\jre6\bin\javaw.exe'

COMMAND = "\"#{JAVA}\" -Xms512m -Xmx1024m -cp \"%APPDATA%\\.minecraft\\bin\\*\" -Djava.library.path=\"%APPDATA%\\.minecraft\\bin\\natives\" net.minecraft.client.Minecraft \"Monkey Brain\""

# http://rubyonwindows.blogspot.com/2007/06/displaying-messagebox-using-windows-api.html
def message_box( title, body )
  user32 = DL.dlopen('user32')
  msgbox = DL::CFunc.new( user32['MessageBoxA'], DL::TYPE_LONG, 'MessageBox' )
  msgbox.call( [0, body, title, 0].pack('L!ppL!').unpack('L!*'))
  raise "#{title}: #{body}"
end

def remaining_minutes
  yaml = YAML.load_file( REMAINING_FILE )
  yaml[:date] == Date.today ? yaml[:remaining] : MINUTES
rescue
  MINUTES
end

def update_remaining_minutes( minutes )
  yaml = { :date => Date.today, :remaining => minutes }.to_yaml
  File.write( REMAINING_FILE, yaml )
end

def timeout_pid(pid, minutes)
  Thread.new do
    sleep minutes * 60
    to_kill = [ pid ]
    Sys::ProcTable.ps do |process|
      to_kill << process.pid if to_kill.include? process.ppid
    end
    Process.kill( :KILL, *to_kill )
  end
  pid
end

def validate_sufficient( time_limit )
  return if time_limit >= MINIMUM_MINUTES
  raise message_box( 'Sorry, Kiddo!', 'No more Minecraft allowed today!' )
end

def run( command, time_limit )
  validate_sufficient time_limit
  pid = timeout_pid( Process.spawn( command ), time_limit )
end

if $0 == __FILE__
  pid = run( COMMAND, remaining_minutes )

  start = Time.now
  Process.waitpid( pid, 0 )
  finish = Time.now

  consumed = ( finish - start ) / 60
  remaining = [ 0, MINUTES - consumed ].sort.last
  update_remaining_minutes( remaining )
end

# vim:ts=2:sw=2:et
