if Rails.env.development? || Rails.env.test?
  Dotenv.require_keys("DB_ADAPTER", "DB_USERNAME", "DB_PASSWORD", "DB_PORT")
end
