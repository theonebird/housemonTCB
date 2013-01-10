# Definition of known client-side routes

# Routes which have a title set will appear in the main menu
# The order in the meny is the order in the reoutes array
module.exports = routes = []

routes.push
  title: 'Home'
  path: '/'

routes.push
  title: 'Admin'
  path: '/admin'

routes.push
  title: 'Sandbox'
  path: '/sandbox'
