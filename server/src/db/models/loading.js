const query = require("../query").query

async function create(scheduleid, locationid, goodid, date, unload) {
  unload = !!unload
  return await query(`INSERT INTO plannedloading (scheduleid, locationid, goodid, date, unload)
  VALUES ($1, $2, $3, $4, $5);
  `, [scheduleid, locationid, goodid, date, unload])
}

async function complete(trainid, locationid, goodid, unload) {
  return await query(`UPDATE loading
  SET completed = true
  WHERE trainid = $1 AND locationid = $2 AND goodid = $3 AND unload = $4;
  `, [trainid, locationid, goodid, unload])
}

module.exports = { create, complete }