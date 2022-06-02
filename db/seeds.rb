# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }]) test2
#   Character.create(name: 'Luke', movie: movies.first)


puts "###########################"
puts " "
puts " destroing data"
User.destroy_all
Choice.destroy_all
Movie.destroy_all
Event.destroy_all
puts " data Destroyed"
puts " "
puts "###########################"
user1 = User.create(email:'ben@mail.com', password:'secret')
user2 = User.create(email:'monna@mail.com', password:'secret')
user3 = User.create(email:'manu@mail.com', password:'secret')
user4 = User.create(email:'dim@mail.com', password:'secret')
user5 = User.create(email:'clem@mail.com', password:'secret')
user6 = User.create(email:'gg@mail.com', password:'secret')
user7= User.create(email:'laeti@mail.com', password:'secret')
user8 = User.create(email: "anael@mail.com", password: "secret")
user9 = User.create(email: "guigui@mail.com", password: "secret")
user10 = User.create(email:'marie@mail.com', password:'secret')
user11 = User.create(email:'vince@mail.com', password:'secret')
puts " User ben@gmail.com created"
puts " Data Creation"
puts " Session Creation"
session1 = Event.create(name: "first session", date: "24/05/2022")
# session1 = Event.create(name: "first session", date: "24/05/2022")
session2 = Event.create(name: 'La deuxieme!!', date: '07/06/2022')
puts " Session Creation DONE"
puts " "
puts " Movie Creation"
movie1 = Movie.create!(title: "Pulp Fiction", kind: "trhiller", poster_url: "https://m.media-amazon.com/images/I/51Dd09FUNLL._AC_.jpg", trailer_url: "https://www.youtube.com/watch?v=tGpTpVyI_OQ")
movie2 = Movie.create!(title: 'Aliens', kind: 'flippete', poster_url:"https://m.media-amazon.com/images/I/41unQZ94ZtL._AC_.jpg", trailer_url:"https://www.youtube.com/watch?v=oSeQQlaCZgU")
puts " End of Movie Creation"
puts " "
puts " Choice Creation"
choice1 = Choice.create(movie: movie1, event: session1, user: user1, ranking: 0)
choice2 = Choice.create(movie: movie2, event: session1, user: user1, ranking: 0)
puts " End  of Choice Creation"
puts " "
puts " End of Data Creation"
puts "###########################"
