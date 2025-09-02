# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding development data..."

# Create test users with different ranks
test_users = [
  {
    email: 'ancient@test.com',
    password: 'password123',
    name: 'Ancient Player',
    nickname: 'AncientGamer',
    phone: '+5511999999001',
    rank_medal: 'ancient',
    rank_stars: 3,
    preferred_position: 'P1',
    positions: ['P1', 'P2']
  },
  {
    email: 'divine@test.com', 
    password: 'password123',
    name: 'Divine Player',
    nickname: 'DivineCoach',
    phone: '+5511999999002',
    rank_medal: 'divine',
    rank_stars: 2,
    preferred_position: 'P3',
    positions: ['P3', 'P4', 'P5']
  },
  {
    email: 'immortal@test.com',
    password: 'password123',
    name: 'Immortal Player',
    nickname: 'ImmortalPro',
    phone: '+5511999999003',
    rank_medal: 'immortal',
    rank_stars: 100, # Immortal rank number
    preferred_position: 'P2',
    positions: ['P1', 'P2', 'P3', 'P4', 'P5']
  }
]

test_users.each do |user_attrs|
  user = User.find_or_create_by(email: user_attrs[:email]) do |u|
    u.password = user_attrs[:password]
    u.name = user_attrs[:name] 
    u.nickname = user_attrs[:nickname]
    u.phone = user_attrs[:phone]
    u.rank_medal = user_attrs[:rank_medal]
    u.rank_stars = user_attrs[:rank_stars]
    u.preferred_position = user_attrs[:preferred_position]
    u.positions = user_attrs[:positions]
  end
  
  puts "✅ User created: #{user.nickname} (#{user.display_rank})"
end

# Create daily lists for today and next few days
(Date.current..Date.current + 3.days).each do |date|
  # Ancient list
  ancient_list = DailyList.find_or_create_by(date: date, list_type: 'ancient', sequence_number: 1) do |list|
    list.status = 'open'
    list.max_players = 5
    list.created_by = 'seed'
  end
  puts "📋 Daily list created: #{ancient_list.display_name} for #{date}"
  
  # Immortal list
  immortal_list = DailyList.find_or_create_by(date: date, list_type: 'immortal', sequence_number: 1) do |list|
    list.status = 'open'
    list.max_players = 5
    list.created_by = 'seed'
  end
  puts "📋 Daily list created: #{immortal_list.display_name} for #{date}"
end

puts "🎉 Seeding completed!"
puts "
Test users created:
- ancient@test.com / password123 (Ancient 3)
- divine@test.com / password123 (Divine 2) 
- immortal@test.com / password123 (Immortal #100)

Daily lists created for today + next 3 days (Ancient & Immortal)
"
