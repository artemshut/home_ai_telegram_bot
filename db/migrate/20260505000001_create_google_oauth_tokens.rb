class CreateGoogleOauthTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :google_oauth_tokens do |t|
      t.references :household, null: false, foreign_key: true, index: { unique: true }
      t.text :access_token
      t.text :refresh_token
      t.string :token_type, default: "Bearer"
      t.datetime :expires_at
      t.string :email
      t.string :scope

      t.timestamps
    end
  end
end
