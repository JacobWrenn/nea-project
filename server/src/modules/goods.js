const db = require("../db")

async function getRecentLocations(username) {
  let locations = await db.location.getRecents(username)
  return locations
}

async function updateRecents(username, locationid) {
  let access = await db.frequents.get(username, locationid)
  if (access) {
    await db.frequents.update(username, locationid, access.count + 1)
  } else {
    await db.frequents.create(username, locationid)
  }
}

async function getGoods(locationid, due) {
  let goods = []
  if (due) {
    goods = await db.good.getDue(locationid)
  } else {
    goods = await db.good.getAt(locationid)
  }
  return goods
}

async function getDetails(goodid) {
  let details = await db.good.getDetails(goodid)
  return details
}

async function getOnTrain(trainid, locationid) {
  let goods = await db.good.getOnTrain(trainid)
  for (let good of goods) {
    good.unloadshere = good.locationid = locationid ? true : false
  }
  return goods
}

async function update(status, goodid) {
  if (status == "received") {
    await db.good.confirmReceived(goodid)
  } else if (status == "handedover") {
    await db.good.confirmHandedOver(goodid)
  }
}

async function updateLoading(trainid, locationid, goodid, unload) {
  await db.loading.complete(trainid, locationid, goodid, unload)
}

module.exports = { getRecentLocations, updateRecents, getGoods, getDetails, getOnTrain, update, updateLoading }