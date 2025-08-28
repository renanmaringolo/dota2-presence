# Seed data for Dota Evolution Presence

puts "🌱 Creating seed data for Dota Evolution Presence..."

# Create Immortal Users (Coaches)
immortals = [
  {
    name: "João Silva",
    nickname: "ProCoach",
    phone: "+5511999999001",
    category: "immortal",
    positions: ["P1", "P2"],
    preferred_position: "P1"
  },
  {
    name: "Maria Santos",
    nickname: "MidQueen",
    phone: "+5511999999002",
    category: "immortal", 
    positions: ["P2"],
    preferred_position: "P2"
  },
  {
    name: "Carlos Oliveira",
    nickname: "OffGod",
    phone: "+5511999999003",
    category: "immortal",
    positions: ["P3"],
    preferred_position: "P3"
  }
]

immortals.each do |user_data|
  user = User.find_or_create_by(nickname: user_data[:nickname]) do |u|
    u.name = user_data[:name]
    u.phone = user_data[:phone]
    u.category = user_data[:category]
    u.positions = user_data[:positions]
    u.preferred_position = user_data[:preferred_position]
    u.active = true
  end
  puts "✅ Created Immortal: #{user.full_display_name}"
end

# Create Ancient Users (Students)
ancients = [
  {
    name: "Renan Proença",
    nickname: "Metallica", 
    phone: "+5511999999004",
    category: "ancient",
    positions: ["P1", "P3"],
    preferred_position: "P1"
  },
  {
    name: "Pedro Costa",
    nickname: "Support4Life",
    phone: "+5511999999005",
    category: "ancient",
    positions: ["P4", "P5"],
    preferred_position: "P5"
  },
  {
    name: "Ana Rodrigues",
    nickname: "CarryMeHome",
    phone: "+5511999999006",
    category: "ancient",
    positions: ["P1"],
    preferred_position: "P1"
  },
  {
    name: "Lucas Ferreira",
    nickname: "MidOrFeed",
    phone: "+5511999999007",
    category: "ancient",
    positions: ["P2"],
    preferred_position: "P2"
  },
  {
    name: "Patricia Lima",
    nickname: "WardMaster",
    phone: "+5511999999008",
    category: "ancient", 
    positions: ["P4", "P5"],
    preferred_position: "P4"
  }
]

ancients.each do |user_data|
  user = User.find_or_create_by(nickname: user_data[:nickname]) do |u|
    u.name = user_data[:name]
    u.phone = user_data[:phone]
    u.category = user_data[:category]
    u.positions = user_data[:positions]
    u.preferred_position = user_data[:preferred_position]
    u.active = true
  end
  puts "✅ Created Ancient: #{user.full_display_name}"
end

# Create today's daily list
today_list = DailyList.find_or_create_by(date: Date.current) do |dl|
  dl.status = 'generated'
  dl.summary = {}
end
puts "✅ Created today's daily list: #{today_list.date}"

# Create some sample presences
sample_presences = [
  { user: "Metallica", position: "P1" },
  { user: "ProCoach", position: "P2" },
  { user: "Support4Life", position: "P5" }
]

sample_presences.each do |presence_data|
  user = User.find_by(nickname: presence_data[:user])
  next unless user

  presence = Presence.find_or_create_by(
    user: user,
    daily_list: today_list,
    position: presence_data[:position]
  ) do |p|
    p.source = 'web'
    p.status = 'confirmed'
    p.confirmed_at = Time.current
  end
  puts "✅ Created presence: #{presence.display_name}" if presence.persisted?
end

puts "\n🎉 Seed data created successfully!"
puts "\nSummary:"
puts "- #{User.immortal.count} Immortal players"
puts "- #{User.ancient.count} Ancient players" 
puts "- #{DailyList.count} Daily list(s)"
puts "- #{Presence.confirmed.count} Confirmed presence(s)"
puts "\n🎮 Ready to start gaming!"