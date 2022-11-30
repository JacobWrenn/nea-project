const db = require("../db")
const fetch = require("node-fetch")

async function getBookings(username) {
  let bookings = db.booking.getByUsername(username)
  return bookings
}

async function getGoodTypes() {
  let types = db.types.getAll()
  return types
}

async function getLocations() {
  let locations = db.location.getAll()
  return locations
}

async function getDestinationStation(address) {
  let geo = await (
    await fetch(`http://api.positionstack.com/v1/forward?access_key=45c1e32b7eed394c0c3cecfa1847b50a&query=${address}`)
  ).json()
  let coords = [geo.data[0].latitude, geo.data[0].longitude]
  let stations = await db.location.getAll()
  // Set a sufficiently high distance to start the comparisons against (it is unlikely anyone can ride an e-bike for 100000km)
  let cDistance = 100000
  let cStation = false
  for (let station of stations) {
    let distance = getDistance(station.lat, station.long, coords[0], coords[1])
    let partner = await db.location.getPartner(station.locationid, distance)
    if (distance < cDistance && partner) {
      cDistance = distance
      cStation = station
    }
  }
  return cStation
}

// This is the Haversine formula, converted into JavaScript by Airikr
function getDistance(lat1, lon1, lat2, lon2) {
  let R = 6371 // Radius of the earth in km
  let dLat = deg2rad(lat2 - lat1)
  let dLon = deg2rad(lon2 - lon1)
  let a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2)
  let c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  let d = R * c // Distance in km
  return Math.round(d)
}

function deg2rad(deg) {
  return deg * (Math.PI / 180)
}

async function genDeliveryPlan(origin, address, arrival, type, volume, internal) {
  let id = (await getDestinationStation(address)).locationid
  if (!id) return false
  let route = await db.schedule.planRoute(origin, id)
  if (!route) return false
  let distance1 = (await db.schedule.getDistance(route.scheduleid1, origin, route.locationid)).sum
  let distance2 = (await db.schedule.getDistance(route.scheduleid2, route.locationid, id)).sum
  if (distance1 == null) {
    // This occurs when there is no change on the route
    distance1 = 0
  }
  let co2 = calculateCO2([[distance1, route.cpm1], [distance2, route.cpm2]])
  let distance = distance1 + distance2
  let endDate = getDate(new Date(arrival), convertDay(route.day2))
  let startDate = getDate(endDate, convertDay(route.day1))
  return {
    price: distance * 1.5,
    start: {
      time: timeFromDate(addHours(dateFromTime(route.time4), -2)),
      date: startDate
    },
    end: {
      time: timeFromDate(addHours(dateFromTime(route.time3), 2)),
      date: endDate
    },
    co2: {
      route: co2,
      lorry: distance * 0.3
    },
    destid: id,
    route: internal ? route : false
  }
}

function timeFromDate(date) {
  let dateString = date.toISOString()
  let timePart = dateString.split("T")
  let parts = timePart[1].split(":")
  return `${parts[0]}:${parts[1]}`
} 

function dateFromTime(time) {
  let split = time.split(":")
  let date = new Date()
  date.setHours(parseInt(split[0]), split[1], 0)
  return date
}

function addHours(date, hours) {
  let ms = 1000 * 60 * 60 * hours
  date.setTime(date.getTime() + ms)
  return date
}

function convertDay(day) {
  day += 1
  day = day % 7
  return day
}

function getDate(date, target) {
  let day = date.getDay()
  let prev = new Date()
  if (day == 0) {
    prev.setDate(date.getDate() - 7 + target)
  }
  else {
    prev.setDate(date.getDate() - (day - target))
  }
  if (prev.getTime() <= (new Date()).getTime()) {
    prev.setDate(prev.getDate() + 7)
  }
  return prev
}

function calculateCO2(legs) {
  let co2 = 0
  for (let leg of legs) {
    co2 += leg[0] * leg[1]
  }
  return co2
}

async function placeBooking(label, origin, address, arrival, type, volume, username) {
  let plan = await genDeliveryPlan(origin, address, arrival, type, volume, true)
  let id = (await db.booking.create(origin, username, address, label, plan.price)).bookingid
  let goodid = (await db.good.create(type, id, volume)).goodid
  // Create planned loadings to correspond to the delivery plan
  await db.loading.create(plan.route.scheduleid1, origin, goodid, plan.start.date)
  await db.loading.create(plan.route.scheduleid2, plan.destid, goodid, plan.end.date, true)
  if (plan.route.id1 != plan.route.id2) {
    await db.loading.create(plan.route.scheduleid1, plan.route.locationid, goodid, plan.start.date, true)
    await db.loading.create(plan.route.scheduleid2, plan.route.locationid, goodid, plan.end.date)
  }
  return id
}

async function getTracking(bookingid) {
  let loadings = db.booking.getTracking(bookingid)
  return loadings
}

module.exports = { getBookings, getGoodTypes, getLocations, genDeliveryPlan, placeBooking, getTracking }