const router = new require('express-promise-router')()

const admin = require("../modules/configuration")
const auth = require("../modules/auth")

router.get("/traction", async (req, res) => {
  res.send(await admin.getTraction())
})

router.post("/createtraction", async (req, res) => {
  res.send(await admin.createTraction(req.body.id, req.body.cpm))
})

router.get("/capacity", async (req, res) => {
  res.send(await admin.getCapacity(req.headers.tractionid))
})

router.post("/createcapacity", async (req, res) => {
  res.send(await admin.createCapacity(req.body.tractionid, req.body.type, req.body.number))
})

router.post("/createtype", async (req, res) => {
  res.send(await admin.createType(req.body.type, req.body.description, req.body.units))
})

router.post("/createlocation", async (req, res) => {
  let { name, lat, long, hub } = req.body
  res.send(await admin.createLocation(name, lat, long, hub))
})

router.post("/createschedule", async (req, res) => {
  let { day, tractionid, start, end, stops } = req.body
  res.send({ success: await admin.createSchedule(day, tractionid, start, end, stops) })
})

router.get("/partners", async (req, res) => {
  res.send(await admin.getPartners())
})

router.post("/createPartner", async (req, res) => {
  let { name, description, url, accessToken } = req.body
  res.send(await admin.createPartner(name, description, url, accessToken))
})

router.post("/createService", async (req, res) => {
  let { locationid, partnerid, radius } = req.body
  res.send(await admin.createService(locationid, partnerid, radius))
})

router.get("/staff", async (req, res) => {
  res.send(await admin.getStaff())
})

router.delete("/staff", async (req, res) => {
  res.send(await admin.deleteStaff(req.body.username))
})

router.post("/createstaff", async (req, res) => {
  res.send(await auth.createUser(req.body.username, req.body.password, "staff"))
})

router.get("/runningtrains", async (req, res) => {
  res.send(await admin.getRunningTrains())
})

router.post("/appenddelay", async (req, res) => {
  res.send({ success: await admin.appendDelay(req.body.trainid, req.body.delay) })
})

router.post("/cancel", async (req, res) => {
  res.send({ success: await admin.cancel(req.body.trainid) })
})

module.exports = router
