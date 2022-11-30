const db = require("../db")

async function getTrains(locationid) {
  let trains = await db.train.getDue(locationid)
  return trains
}

async function getTrainsStarting(locationid) {
  let schedules = await db.schedule.getStarting(locationid)
  return schedules
}

async function startTrain(scheduleid) {
  let trainid = (await db.train.create(scheduleid)).trainid
  await db.train.transferTimings(scheduleid, trainid)
  await db.train.transferLoadings(scheduleid, trainid)
}

module.exports = { getTrains, getTrainsStarting, startTrain }