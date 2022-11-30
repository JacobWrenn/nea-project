const router = new require('express-promise-router')()

const booking = require("../modules/booking")

router.get("/", async (req, res) => {
  res.send({bookings: await booking.getBookings(req.user.username)})
})

router.get("/tracking", async (req, res) => {
  res.send({tracking:await booking.getTracking(req.headers.bookingid)})
})

router.post("/deliveryplan", async (req, res) => {
  let { origin, address, arrival, type, volume } = req.body
  res.send(await booking.genDeliveryPlan(origin, address, arrival, type, volume))
})

router.post("/accept", async (req, res) => {
  let { label, origin, address, arrival, type, volume } = req.body
  res.send({id: await booking.placeBooking(label, origin, address, arrival, type, volume, req.user.username)})
})

router.get("/locations", async (req, res) => {
  res.send({ locations: await booking.getLocations()})
})

router.get("/types", async (req, res) => {
  res.send({ types: await booking.getGoodTypes()})
})

module.exports = router