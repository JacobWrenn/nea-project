const user = require("./models/user")
const types = require("./models/type")
const train = require("./models/train")
const traction = require("./models/traction")
const schedule = require("./models/schedule")
const partners = require("./models/partners")
const location = require("./models/location")
const loading = require("./models/loading")
const good = require("./models/good")
const frequents = require("./models/frequentaccess")
const booking = require("./models/booking")

// Make all the different entities available under one identifier
module.exports = {
  user,
  types,
  train,
  traction,
  schedule,
  partners,
  location,
  loading,
  good,
  frequents,
  booking
}