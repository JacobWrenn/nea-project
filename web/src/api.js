import jwt_decode from "jwt-decode";

class Api {
  constructor() {
    this.server = "http://localhost:8080"
    this.token = ""
  }

  restore() {
    // Use local storage as a substitute for the keychain avaialble on mobile devices
    this.token = window.localStorage.getItem("intelligentlogin")
    if (this.token && jwt_decode(this.token).accesslevel == "admin") {
      return true
    }
    return false
  }

  login() {
    const popup = window.open(`${this.server}/auth/login?redirect=${window.location.href}`, "", { popup: true })
    let interval;
    // Wrap the popup handling logic in a promise so that it will be presented as one single process to other parts of the program
    return new Promise((resolve, reject) => {
      interval = setInterval(() => {
        if (popup.location.href) {
          const urlParams = new URLSearchParams(popup.location.search)
          const token = urlParams.get("token")
          clearInterval(interval)
          popup.close()
          if (token && jwt_decode(token).accesslevel == "admin") {
            this.token = token
            window.localStorage.setItem("intelligentlogin", token)
            resolve(true)
          }
          reject()
        }
      }, 500)
    })
  }

  logout() {
    this.token = ""
    window.localStorage.clear()
  }

  async makefetch(url, method, headers, body) {
    const res = await fetch(`${this.server}${url}`, {
      method,
      headers: {"Content-Type": "application/json", "token": this.token, ...headers},
      body: body ? JSON.stringify(body) : undefined
    })
    return await res.json()
  }

  get(url, headers) {
    return this.makefetch(url, "GET", headers)
  }

  post(url, headers, body) {
    return this.makefetch(url, "POST", headers, body)
  }

  delete(url, headers, body) {
    return this.makefetch(url, "DELETE", headers, body)
  }
}

const instance = new Api()

export default instance