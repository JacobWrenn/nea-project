const query = require("../query").query

async function get(username, locationid) {
  return (await query(`SELECT * FROM frequentaccess f
  WHERE f.username = $1 AND f.locationid = $2;
  `, [username, locationid])).rows[0]
}

async function create(username, locationid) {
  return await query(`INSERT INTO frequentaccess (username, locationid, count)
  VALUES ($1, $2, 1);
  `, [username, locationid])
}

async function update(username, locationid, count) {
  return await query(`UPDATE frequentaccess f
  SET count = $3
  WHERE f.username = $1 AND f.locationid = $2;
  `, [username, locationid, count])
}

module.exports = { get, create, update }