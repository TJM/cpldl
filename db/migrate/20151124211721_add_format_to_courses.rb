class AddFormatToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :format, :string
  end
end
