const query = require("../query").query

async function create(id, cpm) {
  return await query(`INSERT INTO tractiontype (tractionid, carbonpermile)
  VALUES ($1, $2);
  `, [id, cpm])
}

async function createCapacity(tractionid, type, number) {
  return await query(`INSERT INTO loadingcapacity (tractionid, goodtype, number)
  VALUES ($1, $2, $3);
  `, [tractionid, type, number])
}

async function getCapacity(tractionid) {
  return (await query(`SELECT * FROM loadingcapacity
  WHERE tractionid = $1;
  `, [tractionid])).rows
}

async function getAll() {
  return (await query(`SELECT * FROM tractiontype;`, [])).rows
}

module.exports = { create, createCapacity, getCapacity, getAll }