# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

AdminUser.create!(email: 'admin@touchcard.co', password: 'expert_lethargic_oarsman', password_confirmation: 'expert_lethargic_oarsman')
Plan.create!(amount: 99, interval: "month", name: "$0.99/month", currency: "usd", interval_count: 1, on_stripe: true)

