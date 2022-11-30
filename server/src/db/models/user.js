const query = require("../query").query

async function create(username, passwordHash, accessLevel) {
  try {
    await query("INSERT INTO users (username, passwordhash, accesslevel) VALUES ($1, $2, $3);", [username, passwordHash, accessLevel])
    return true
  } catch {
    return false
  }
}

async function getByUsername(username) {
  return (await query("SELECT * FROM users WHERE username = $1;", [username])).rows[0]
}

async function deleteStaff(username) {
  try {
    await query(`DELETE from users
    WHERE username = $1 AND accesslevel = 'staff';
    `, [username])
    return true
  } catch {
    return false
  }
}

async function getAllStaff() {
  return (await query(`SELECT username from users
  WHERE accesslevel = 'staff';
  `, [])).rows
}

module.exports = { create, getByUsername, deleteStaff, getAllStaff }