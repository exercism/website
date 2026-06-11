class User::JikiStatuses
  include Mandate

  initialize_with :user_ids

  def call
    user_ids.map do |id|
      row = rows_by_id[id.to_i]
      {
        exercism_id: id.to_i,
        is_insider: row ? insider?(row) : false,
        is_bootcamp_member: row ? bootcamp_member?(row) : false
      }
    end
  end

  private
  ACTIVE_INSIDER_STATUSES = %w[active active_lifetime].freeze
  private_constant :ACTIVE_INSIDER_STATUSES

  def insider?(row)
    ACTIVE_INSIDER_STATUSES.include?(row[:insiders_status])
  end

  def bootcamp_member?(row)
    row[:bootcamp_attendee] || row[:bootcamp_mentor] ||
      row[:enrolled_on_part_1] || row[:enrolled_on_part_2]
  end

  PLUCKED_COLUMNS = [
    :id,
    'user_data.insiders_status',
    'user_data.bootcamp_attendee',
    'user_data.bootcamp_mentor',
    'user_bootcamp_data.enrolled_on_part_1',
    'user_bootcamp_data.enrolled_on_part_2'
  ].freeze
  private_constant :PLUCKED_COLUMNS

  memoize
  def rows_by_id
    return {} if user_ids.blank?

    User.where(id: user_ids).joins(:data).left_joins(:bootcamp_data).
      pluck(*PLUCKED_COLUMNS).
      each_with_object({}) do |row, hash|
        hash[row[0]] = {
          insiders_status: row[1],
          bootcamp_attendee: row[2],
          bootcamp_mentor: row[3],
          enrolled_on_part_1: row[4] || false,
          enrolled_on_part_2: row[5] || false
        }
      end
  end
end
