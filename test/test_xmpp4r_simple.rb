$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'test/unit'
require 'timeout'
require 'xmpp4r-simple'

class JabberSimpleTest < Test::Unit::TestCase

  def setup
    @initialized ||= false

    if @initialized
      return true
    else
      @initialized = true
    end

    logins = []
    begin
      logins = File.readlines(File.expand_path("~/.xmpp4r-simple-test-config")).map! { |login| login.split(" ") }
      raise StandardError unless logins.size == 2
    rescue => e
      puts "\nConfiguration Error!\n\nYou must make available two unique Jabber accounts in order for the tests to pass."
      puts "Place them in ~/.xmpp4r-simple-test-config, one per line like so:\n\n"
      puts "user1@example.com/res password"
      puts "user2@example.com/res password\n\n"
      raise e
    end

    @client1 = Jabber::Simple.new(*logins[0])
    @client2 = Jabber::Simple.new(*logins[1])

    @jid1_raw = Jabber::JID.new(logins[0][0])
    @jid2_raw = Jabber::JID.new(logins[1][0])

    @jid1 = @jid1_raw.strip.to_s
    @jid2 = @jid2_raw.strip.to_s

    # Force load the client and roster, just to be safe.
    @client1.roster
    @client2.roster
  end

  def test_ensure_the_jabber_clients_are_connected_after_setup
    assert @client1.client.is_connected?
    assert @client2.client.is_connected?
  end

  def test_inspect_should_be_custom
    assert_equal "Jabber::Simple #{@jid1_raw}", @client1.inspect
  end

  def test_inspect_contact_should_be_custom
    assert_equal "Jabber::Contact #{@jid2}", @client1.contacts(@jid2).inspect
  end

  def test_remove_users_from_our_roster_should_succeed
    @client2.remove(@jid1)
    @client1.remove(@jid2)

    sleep 3

    assert_equal false, @client1.subscribed_to?(@jid2)
    assert_equal false, @client2.subscribed_to?(@jid1)
  end

  def test_add_users_to_our_roster_should_succeed_with_automatic_approval
    @client1.remove(@jid2)
    @client2.remove(@jid1)

    assert_before 60 do
      assert_equal false, @client1.subscribed_to?(@jid2)
      assert_equal false, @client2.subscribed_to?(@jid1)
    end

    sleep 2
    @client1.add(@jid2)

    assert_before 60 do
      assert @client1.subscribed_to?(@jid2)
      assert @client2.subscribed_to?(@jid1)
    end
  end

  def test_sent_message_should_be_received
    # First clear the client's message queue, just in case.
    assert_kind_of Array, @client2.received_messages

    # Next ensure that we're not subscribed, so that we can test the deferred message queue.
    @client1.remove(@jid2)
    @client2.remove(@jid1)
    sleep 2

    # Deliver the messages; this should be received by the other client.
    @client1.deliver(@jid2, "test message")

    sleep 2

    # Fetch the message; allow up to ten seconds for the delivery to occur.
    messages = []
    begin
      Timeout::timeout(10) {
        loop do
          messages = @client2.received_messages
          break unless messages.empty?
          sleep 1
        end
      }
    rescue Timeout::Error
      flunk "Timeout waiting for message"
    end

    # Ensure that the message was received intact.
    assert_equal @jid1, messages.first.from.strip.to_s
    assert_equal "test message", messages.first.body
  end

  def test_automatically_reconnect
    @client1.client.close

    assert_before 60 do
      assert_equal false, @client1.connected?
    end

    # empty client 2's received message queue.
    @client2.received_messages

    @client1.deliver(@jid2, "Testing")

    assert_before(60) { assert @client1.connected? }
    assert_before(60) { assert_equal 1, @client2.received_messages.size }
  end

  def test_disconnect_doesnt_allow_auto_reconnects
    @client1.disconnect

    assert_equal false, @client1.connected?
    
    assert_raises Jabber::ConnectionError do
      @client1.deliver(@jid2, "testing")
    end

    @client1.reconnect
  end

  private

  def assert_before(seconds, &block)
    error = nil
    begin
      Timeout::timeout(seconds) {
        begin
          yield
        rescue => e
          error = e
          sleep 0.5
          retry
        end
      }
    rescue Timeout::Error
      raise error
    end
  end

end
