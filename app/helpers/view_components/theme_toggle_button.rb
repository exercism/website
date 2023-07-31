module ViewComponents
  module ThemeToggleButton
    def toggle_button
      tag.div class: 'toggle-button' do
        tag.label id: 'switch', class: 'switch' do
          tag.input(type: 'checkbox', id: "slider") <<
            tag.span(class: 'slider round')
        end
      end
    end
  end
end
