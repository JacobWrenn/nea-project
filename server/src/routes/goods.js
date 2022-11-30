const router = new require('express-promise-router')()

const goods = require("../modules/goods")

router.get("/get", async (req, res) => {
  res.send(await goods.getGoods(req.headers.locationid, req.headers.due === "true"))
})

router.get("/frequents", async (req, res) => {
  res.send(await goods.getRecentLocations(req.user.username))
})

router.post("/frequents", async (req, res) => {
  res.send({success:await goods.updateRecents(req.user.username, req.body.locationid)})
})

router.get("/details", async (req, res) => {
  res.send(await goods.getDetails(req.headers.goodid))
})

router.get("/getontrain", async (req, res) => {
  res.send(await goods.getOnTrain(req.headers.trainid))
})

router.post("/update", async (req, res) => {
  // Differentiate between status stored on the good and status stored on individual loadings
  if (req.body.goodStatus) {
    await goods.update(req.body.status, req.body.goodid)
  } else {
    await goods.updateLoading(req.body.trainid, req.body.locationid, req.body.goodid, req.body.unload)
  }
  res.send("OK")
})

module.exports = router