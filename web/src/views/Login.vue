<template>
  <div id="login">
    <h1>Intelligent Platform</h1>
    <p>Login with your admin account to configure the platform here.</p>
    <div class="button" @click="login">Login</div>
  </div>
</template>

<script>
import api from "../api"

export default {
  methods: {
    login() {
      api.login().then(res => {
        if (res) this.$store.commit("setLogIn", true)
      }).catch(() => {
        // Catch clause directs the program on what to do if the login fails (i.e. the user wasn't an admin)
        alert("Insufficient access level!")
      })
    },
  },
  mounted() {
    if (api.restore()) this.$store.commit("setLogIn", true)
  }
};
</script>

<style lang="scss" scoped>
#login {
  background: #00052f;
  display: flex;
  color: white;
  flex-direction: column;
  height: 100vh;
  justify-content: center;
  align-items: center;

  * {
    margin-bottom: 1em;
  }

  .button {
    margin: 2em;
    background: #c4c4c4;
    color: black;
    padding: 1em 2em 1em 2em;
    font-size: 1.2em;
    cursor: pointer;
    border-radius: 0.5em;

    &:hover {
      background: #808080;
    }
  }
}
</style>