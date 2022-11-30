const router = new require('express-promise-router')()

const train = require("../modules/scheduler")

router.get("/get", async (req, res) => {
  res.send(await train.getTrains(req.headers.locationid))
})

router.get("/getstarting", async (req, res) => {
  res.send(await train.getTrainsStarting(req.headers.locationid))
})

router.post("/start", async (req, res) => {
  res.send(await train.startTrain(req.body.scheduleid))
})

module.exports = router