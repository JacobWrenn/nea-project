const query = require("../query").query

async function getAll() {
  return (await query(`SELECT * FROM location;`, [])).rows
}

async function getPartner(locationid, distance) {
  return (await query(`SELECT p.partnerid
  FROM deliverypartner p
  INNER JOIN locationserved l
  ON p.partnerid = l.partnerid
  WHERE l.locationid = $1 AND $2 <= l.radius;
  `, [locationid, distance])).rows[0]
}

async function getRecents(username) {
  return (await query(`SELECT l.locationid, l.name
  FROM location l
  INNER JOIN frequentaccess f
  ON f.locationid = l.locationid
  WHERE f.username = $1
  ORDER BY f.count DESC;
  `, [username])).rows
}

async function create(name, lat, long, hub) {
  return await query(`INSERT INTO location (name, lat, long, hub)
  VALUES ($1, $2, $3, $4);
  `, [name, lat, long, hub])
}

module.exports = { getAll, getPartner, getRecents, create }