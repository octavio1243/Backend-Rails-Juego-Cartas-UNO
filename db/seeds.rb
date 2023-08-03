# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

=begin

# Deprecado porque se usará Enum a partir de ahora

colors = ['Rojo', 'Amarillo', 'Azul', 'Verde']
values = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

colors.each do |color|
  values.each do |value|
    Card.create(tipo: 'Numero', color: color, valor: value)
  end
end

colors.each do |color|
  Card.create(tipo: 'Mas dos', color: color)
  Card.create(tipo: 'Reversa', color: color)
end

Card.create(tipo: 'Mas cuatro')
Card.create(tipo: 'Colores')

Status.create(name: 'En espera')
Status.create(name: 'En curso')
Status.create(name: 'Finalizado')

=end