# coding: utf-8

User.create!(name: "管理者",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: 101,
             admin: true)
             
User.create!(name: "上長1",
             email: "superior-1@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: 201,
             superior: true)

User.create!(name: "上長2",
             email: "superior-2@email.com",
             password: "password",
             password_confirmation:"password",
             employee_number: 202,
             superior: true)

60.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n + 1}@email.com"
  password = "password"
  employee_number = (n + 1) + 300
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               employee_number: employee_number)

end