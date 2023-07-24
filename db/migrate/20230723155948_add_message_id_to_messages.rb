class AddMessageIdToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :message_id, :string
  end
end
