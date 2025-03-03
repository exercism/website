class AddCustomFunctionsToSolutions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :bootcamp_submissions, :custom_functions, :text, null: false
    add_column :bootcamp_custom_functions, :depends_on, :text, null: false

    Bootcamp::Submission.update_all(custom_functions: [])
    Bootcamp::CustomFunction.update_all(depends_on: [])
  end
end
