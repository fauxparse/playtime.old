class JesterSession < Authlogic::Session::Base
  include Authlogic::Session::MagicStates
end
