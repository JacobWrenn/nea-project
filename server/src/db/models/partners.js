const query = require("../query").query

async function getAll() {
  return (await query(`SELECT * FROM deliverypartner;`, [])).rows
}

async function create(name, description, url, accessToken) {
  return await query(`INSERT INTO deliverypartner (name, description, url, accesstoken)
  VALUES ($1, $2, $3, $4);
  `, [name, description, url, accessToken])
}

async function createService(locationid, partnerid, radious) {
  return await query(`INSERT INTO locationserved (locationid, partnerid, radius)
  VALUES ($1, $2, $3);
  `, [locationid, partnerid, radious])
}

module.exports = { getAll, create, createService }