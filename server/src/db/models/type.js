const query = require("../query").query

async function getAll() {
  return (await query(`SELECT * FROM goodtype;`, [])).rows
}

async function create(type, description, units) {
  return await query(`INSERT INTO goodtype (goodtype, description, units)
  VALUES ($1, $2, $3);
  `, [type, description, units])
}

module.exports = { getAll, create }