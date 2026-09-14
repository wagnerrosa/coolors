admin_email = ENV["ADMIN_EMAIL"]
admin_password = ENV["ADMIN_PASSWORD"]

if admin_email.present? && admin_password.present?
  User.find_or_create_by!(email: admin_email) do |u|
    u.password = admin_password
    u.admin = true
  end
  puts "Admin ready: #{admin_email}"
else
  puts "ADMIN_EMAIL / ADMIN_PASSWORD not set - skipping admin creation"
end

if Color.none?
  [
    %w[#27B6BA #C5FF49 #485451],
    %w[#E95787 #FFD068 #FFEEE4],
    %w[#F17F42 #E52054 #AAAFC6],
    %w[#349B9F #C5FF49 #333030]
  ].each do |c1, c2, c3|
    Color.create!(color1: c1, color2: c2, color3: c3)
  end
  puts "Seeded #{Color.count} palettes"
end
