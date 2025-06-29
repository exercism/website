ActiveSupport::Notifications.subscribe('sql.active_record') do |_, _, _, _, details|
  if details[:sql] == "SELECT COUNT(*) FROM `solutions`"
    Rails.logger.error "🔍 COUNT query triggered from:"
    Rails.logger.error caller.select { |line| line.include?(Rails.root.to_s) }.join("\n")
  end
end
