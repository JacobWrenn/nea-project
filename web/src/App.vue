<template>
  <div id="app">
    <Login v-if="!loggedIn"></Login>
    <Main v-else></Main>
  </div>
</template>

<script>
import Login from "./views/Login.vue";
import Main from "./views/Main.vue";
import { mapState } from "vuex";

export default {
  name: "App",
  computed: mapState(["loggedIn"]),
  components: {
    Login,
    Main,
  },
};
</script>

<style>
</style>
