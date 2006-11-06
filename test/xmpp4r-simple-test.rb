require 'test/unit'
require 'timeout'
require '../lib/xmpp4r-simple'

class JabberSimpleTest < Test::Unit::TestCase

  def setup
    @client1 = Jabber::Simple.new("jabbertest01@gmail.com/test", "twitter2006")
    @client2 = Jabber::Simple.new("jabbertest02@gmail.com/test", "twitter2006")
  end

  def add_user_to_roster_should_result_in_authorization_requests_and_users_in_both_rosters
  end

  def remove_user_from_roster_should_remove_users_from_both_rosters
  end

  def test_sent_message_should_be_received
    @client1.deliver("jabbertest02@gmail.com", "test message")

    messages = []
    
    Timeout::timeout(5) {
      loop do
        messages = @client2.received_messages
        break unless messages.empty?
      end
    }

    assert_equal "jabbertest01@gmail.com", messages.first.from.strip.to_s
    assert_equal "test message", messages.first.body
  end

end
