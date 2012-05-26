require 'wx'

module MCLimit
  class AdminDialog < Wx::Dialog
    def initialize(parent, value)
      super( parent, -1, 'Minecraft Limiter Administration' )

      sizer = Wx::FlexGridSizer.new( 1, 2, 0, 0 )
      label = Wx::StaticText.new( self, -1, 'Minutes of game play remaining:' )
      sizer.add( label, 0, Wx::ALL, 4 )
      @expand = Wx::SpinCtrl.new( self )
      @expand.set_range(0, 1440)
      @expand.set_value(value)
      @expand.set_selection(-1, -1)
      sizer.add( @expand, 0, Wx::ALL, 4 )

      topsizer = Wx::GridSizer.new( 2, 1, 0, 0 )
      topsizer.add( sizer, 0, Wx::ALL, 4 )
      topsizer.add( create_std_dialog_button_sizer( Wx::OK | Wx::CANCEL ), 0, Wx::ALL, 4 )
      self.set_sizer( topsizer )
      topsizer.set_size_hints( self )
      topsizer.fit( self )
      @expand.set_focus
    end

    def value
      @expand.get_value
    end
  end

  def self.check_admin_password( parent )
    raise 'Administration password has not been set!' if MCLimit.admin_password.nil?
    password = Wx::PasswordEntryDialog.new( parent, 'Enter administration password' )
    raise 'Password required!' unless Wx::ID_OK == password.show_modal
    raise 'Incorrect password!' unless password.get_value == MCLimit.admin_password
  end

  class AdminApp < Wx::App
    def on_init
      frame = Wx::Frame.new(nil, -1, 'Dialog')
      begin
        MCLimit.check_admin_password( frame )
        admin = AdminDialog.new( frame, MCLimit.remaining_minutes.to_i )
        MCLimit.update_remaining_minutes( admin.value ) if Wx::ID_OK == admin.show_modal
      rescue => e
        GUI.error( e.message )
        raise if $DEBUG
      ensure
        frame.close
      end
    end
  end

  def self.admin
    AdminApp.new.main_loop
  end
end

# vim:ts=2:sw=2:et
