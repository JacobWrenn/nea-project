const db = require("../db")
const booking = require("./booking")

async function getTraction() {
  return await db.traction.getAll()
}

async function createTraction(id, cpm) {
  return await db.traction.create(id, cpm)
}

async function getCapacity(tractionid) {
  return await db.traction.getCapacity(tractionid)
}

async function createCapacity(tractionid, type, number) {
  return await db.traction.createCapacity(tractionid, type, number)
}

async function createType(type, description, units) {
  return await db.types.create(type, description, units)
}

async function createLocation(name, lat, long, hub) {
  return await db.location.create(name, lat, long, hub)
}

async function createSchedule(day, tractionid, start, end, stops) {
  let id = (await db.schedule.create(day, tractionid, start, end)).scheduleid
  for (let stop of stops) {
    await db.schedule.addStop(id, stop.locationid, stop.time, stop.distance)
  }
}

async function getPartners() {
  return await db.partners.getAll()
}

async function createPartner(name, description, url, accessToken) {
  return await db.partners.create(name, description, url, accessToken)
}

async function createService(locationid, partnerid, radius) {
  return await db.partners.createService(locationid, partnerid, radius)
}

async function getStaff() {
  return await db.user.getAllStaff()
}

async function deleteStaff(username) {
  return await db.user.deleteStaff(username)
}

async function getRunningTrains() {
  return await db.train.getAllRunning()
}

async function appendDelay(trainid, delay) {
  return await db.train.appendDelay(trainid, delay)
}

async function cancel(trainid) {
  let goods = await db.good.getOnTrain(trainid)
  let nextStation = await db.train.getNextStation(trainid)
  let today = new Date()
  today.setDate(today.getDate() + 1)
  for (let good of goods) {
    // Every good on the cancelled train needs a new delivery plan
    let newPlan = await booking.genDeliveryPlan(nextStation.locationid, good.destination, today.getTime(), good.type, good.volume, true)
    await db.good.cancelLoadings(good.goodid)
    await db.good.cancelPlannedLoadings(good.goodid)
    await actionNewPlan(newPlan, good, nextStation.locationid)
  }
  await db.train.cancel(trainid)
}

async function actionNewPlan(plan, good, nextStation) {
  // Create new planned loadings to get the goods to their destinations
  await db.loading.create(plan.route.scheduleid1, nextStation, good.goodid, plan.start.date)
  await db.loading.create(plan.route.scheduleid2, plan.destid, good.goodid, plan.end.date)
  if (plan.route.scheduleid1 != plan.route.scheduleid2) {
    await db.loading.create(plan.route.scheduleid1, route.locationid, good.goodid, plan.start.date, true)
    await db.loading.create(plan.route.scheduleid2, route.locationid, good.goodid, plan.end.date)
  }
}

module.exports = { getTraction, createTraction, getCapacity, createCapacity, createType, createLocation, createSchedule, getPartners, createPartner, createService, getStaff, deleteStaff, getRunningTrains, appendDelay, cancel }