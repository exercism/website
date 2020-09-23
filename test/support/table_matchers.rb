module TableMatchers
  def assert_table_row(table, fields, index = 0)
    within(table) do
      headers = all("th").map(&:text)

      fields.each do |header, assertion|
        position = headers.index(header)

        within("tbody > tr:nth-child(#{index + 1}) > td:nth-child(#{position + 1})") do
          if assertion.respond_to?(:call)
            assertion.()
          elsif assertion.is_a?(String)
            assert_text assertion
          end
        end
      end
    end
  end
end
