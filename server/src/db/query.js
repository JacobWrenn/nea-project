const { Pool } = require('pg')

// Connect to postgres using PG library
const pool = new Pool({
  user: 'jacob',
  host: 'localhost',
  database: 'server',
  password: '',
  port: 5432,
})

// Expose the ability to send SQL requests for use in other files
module.exports = {
  query: (text, params, callback) => {
    return pool.query(text, params, callback)
  },
}