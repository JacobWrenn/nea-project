const jwt = require("jsonwebtoken")
const bcrypt = require("bcrypt")
const fs = require("fs")
const path = require("path")

const db = require("../db")

async function createUser(username, password, accessLevel) {
  try {
    let passwordHash = await bcrypt.hash(password, 10)
    return await db.user.create(username, passwordHash, accessLevel)
  } catch {
    return false
  }
}

async function login(username, password) {
  try {
    let user = await db.user.getByUsername(username)
    if (await bcrypt.compare(password, user.passwordhash)) {
      // Use __dirname to reference the key relative to the server directory, regardless of where it is stored
      let privateKey = await fs.promises.readFile(path.join(__dirname, "../../jwt.key"))
      return await createToken(user, privateKey)
    } else {
      return false
    }
  } catch {
    return false
  }
}

async function decodeUser(token) {
  try {
    let publicKey = await fs.promises.readFile(path.join(__dirname, "../../jwt.pem"))
    return await verifyToken(token, publicKey)
  } catch {
    return false
  }
}

// Wrap methods from the JWT library in promises to make them easier to use
function createToken(json, privateKey) {
  json.passwordhash = null;
  return new Promise((resolve, reject) => {
    jwt.sign(json, privateKey, { algorithm: 'RS256' }, function (err, token) {
      if (err) return reject(err)
      return resolve(token)
    });
  })
}

function verifyToken(token, publicKey) {
  return new Promise((resolve, reject) => {
    jwt.verify(token, publicKey, { algorithms: 'RS256' }, function (err, decoded) {
      if (err) return reject(err)
      return resolve(decoded)
    });
  })
}

function middleware(req, res, next) {
  if (req.headers.token) {
    decodeUser(req.headers.token).then(user => {
      req.user = user
      next()
    }).catch(err => {
      next()
    })
  } else {
    next()
  }
}

// Returns a new piece of middleware that protects to the specified access level
function protect(accesslevel) {
  return function (req, res, next) {
    if (req.user && (req.user.accesslevel == accesslevel || req.user.accesslevel == "admin" || (accesslevel == "user" && req.user.accesslevel == "staff"))) {
      next()
    } else {
      res.status(403)
      res.end()
    }
  }
}

module.exports = {
  createUser,
  login,
  decodeUser,
  middleware,
  protect
}