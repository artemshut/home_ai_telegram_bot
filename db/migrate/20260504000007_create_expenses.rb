class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.references :household,        null: false, foreign_key: true
      t.references :expense_category, null: false, foreign_key: true
      t.references :telegram_user,    foreign_key: true
      t.decimal    :amount,           null: false, precision: 10, scale: 2
      t.string     :currency,         null: false, default: "EUR"
      t.text       :description,      null: false
      t.date       :spent_on,         null: false
      t.timestamps
    end

    add_index :expenses, :spent_on
  end
end
