# TEMPORARY diagnostics for flaky websocket tests. To be reverted.
module CableDiagnostics
  def with_cable_diagnostics(label)
    log = StringIO.new
    original = ActionCable.server.config.logger
    logger = ActiveSupport::Logger.new(log)
    logger.level = :debug
    logger.formatter = proc { |_s, t, _p, msg| "#{t.strftime('%H:%M:%S.%L')} [#{Thread.current.object_id}] #{msg}\n" }
    ActionCable.server.config.logger = logger
    yield
  ensure
    ActionCable.server.config.logger = original
    puts "\n===== CABLE LOG #{label} =====\n#{log.string}===== END CABLE LOG =====\n"
  end

  def dump_cable_state(label)
    lines = ["===== CABLE STATE #{label} #{Time.current.strftime('%H:%M:%S.%L')}"]
    ActionCable.server.connections.each do |c|
      c.subscriptions.send(:subscriptions).each do |id, s|
        lines << "  server sub #{id} confirmed=#{s.send(:subscription_confirmation_sent?).inspect} " \
                 "unsubscribed=#{s.unsubscribed?.inspect} streams=#{s.send(:streams).keys.inspect}"
      end
    end
    subscribers = ActionCable.server.pubsub.send(:subscriber_map).instance_variable_get(:@subscribers)
    lines << "  pubsub #{subscribers.transform_values(&:size).inspect}"
    lines << "  client #{page.evaluate_script(<<~JS)}"
      (function() {
        var c = window.$$actionCableConsumer
        var pending = c.subscriptions.guarantor.pendingSubscriptions
        return JSON.stringify({
          open: c.connection.isOpen(),
          pingedAt: c.connection.monitor.pingedAt,
          disconnectedAt: c.connection.monitor.disconnectedAt,
          subs: c.subscriptions.subscriptions.map(function(s) { return [s.identifier, pending.indexOf(s) !== -1] })
        })
      })()
    JS
    puts lines.join("\n")
  rescue StandardError => e
    puts "dump_cable_state failed: #{e.class} #{e.message}"
  end
end
