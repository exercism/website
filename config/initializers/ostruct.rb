class OpenStruct
  # Prevent OpenStruct arrays from being rendered in a container "table" key
  # See https://stackoverflow.com/questions/7835047/collecting-hashes-into-openstruct-creates-table-entry
  def as_json(options = nil) = @table.as_json(options)
end
