require 'wx'

module MCLimit
  class GUI < Wx::App
    def on_init
      frame = Wx::Frame.new(nil, -1, 'Hidden')
      @main.call
    ensure
      frame.close
    end
    def main_loop(&main)
      @main = main
      super
    end

    def self.error( message, title = 'Error' )
      dialog = Wx::MessageDialog.new( nil, message, title, Wx::OK | Wx::ICON_ERROR )
      dialog.show_modal
    end
  end
end

# vim:ts=2:sw=2:et
