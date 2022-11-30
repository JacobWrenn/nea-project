const fs = require("fs")
const path = require("path")
const router = new require('express-promise-router')()

const auth = require("../modules/auth")


router.get("/login", (req, res) => {
  res.status(200);
  res.setHeader('Content-Type', 'text/html')
  fs.createReadStream(path.join(__dirname, '../static', 'login.html')).pipe(res)
})

router.post("/login", async (req, res) => {
  let login = await auth.login(req.body.username, req.body.password)
  if (login) {
    res.redirect(`${req.query.redirect}?token=${login}`)
  } else {
    res.redirect(`/auth/login?redirect=${req.query.redirect}&incorrect=true`)
  }
})

router.get("/register", (req, res) => {
  res.status(200);
  res.setHeader('Content-Type', 'text/html')
  fs.createReadStream(path.join(__dirname, '../static', 'register.html')).pipe(res)
})

router.post("/register", async (req, res) => {
  if (req.body.password != req.body.password2) {
    return res.redirect(`/auth/register?redirect=${req.query.redirect}&error=nomatch`)
  }
  // When creating a user, immediately log in using the provided detals
  if (await auth.createUser(req.body.username, req.body.password, "user")) {
    token = await auth.login(req.body.username, req.body.password)
    res.redirect(`${req.query.redirect}?token=${token}`)
  } else {
    res.redirect(`/auth/register?redirect=${req.query.redirect}&error=nametaken`)
  }
})

module.exports = router