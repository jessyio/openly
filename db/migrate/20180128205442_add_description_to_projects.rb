# frozen_string_literal: true

# Add description to projects
class AddDescriptionToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :description, :text
  end
end
