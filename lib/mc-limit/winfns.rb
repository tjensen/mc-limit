require 'win32/api'

module MCLimit
  module Win
    WM_DESTROY = 0x2
    WM_CLOSE = 0x10
    WM_QUIT = 0x12

    MessageBox = Win32::API.new('MessageBox', 'LSSI', 'I', 'user32')
    SendMessage = Win32::API.new('SendMessage', 'LLLL', 'I', 'user32')
    EnumWindows = Win32::API.new('EnumWindows', 'KP', 'L', 'user32')
    GetWindowText = Win32::API.new('GetWindowText', 'LPI', 'I', 'user32')
    GetWindowThreadProcessId = Win32::API.new('GetWindowThreadProcessId', 'LP', 'L', 'user32')

    def self.message_box(title, body)
      MessageBox.call(0, body, title, 0)
    end

    def self.window_for_pid(pid, text)
      result = nil
      finder = Win32::API::Callback.new('LP', 'I') do |handle, param|
        pidp = [0].pack('L')
        GetWindowThreadProcessId.call(handle, pidp)
        if pid == pidp.unpack('L')[0]
          buf = "\0" * 200
          GetWindowText.call(handle, buf, 200)
          result = handle if buf.strip == text
        end
        true
      end
      EnumWindows.call(finder, nil)
      result
    end

    def self.close_process(pids, text)
      pids.each do |pid|
        handle = window_for_pid(pid, 'Minecraft')
        next if handle.nil?
        SendMessage.call(handle, WM_CLOSE, 0, 0)
        break
      end
    end
  end
end

# vim:ts=2:sw=2:et
