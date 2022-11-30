<template>
  <div id="sidebar">
    <div class="row">
      <h2>Intelligent Platform</h2>
      <div class="button" @click="logout">Logout</div>
    </div>
    <div id="btnColumn">
      <div v-for="ctab in tabs" :key="ctab.tab" v-bind:class="{'button': true, 'active': tab == ctab.tab}" @click="openTab(ctab.tab)">{{ ctab.name }}</div>
    </div>
  </div>
</template>

<script>
import api from "../api";
import { mapState } from "vuex";

export default {
  computed: mapState(["tab"]),
  data() {
    // Labels for each tab and id to associate each with a specific component
    return {tabs: [
      {name: "Configure Trains", tab: "trains"},
      {name: "Schedules / Locations", tab: "schedules"},
      {name: "Integrations", tab: "integrations"},
      {name: "User Accounts", tab: "users"},
      {name: "Delays / Cancellations", tab: "delay"},
    ]}
  },
  methods: {
    logout() {
      api.logout();
      this.$store.commit("setLogIn", false);
    },
    openTab(tab) {
      this.$store.commit("setTab", tab)
    }
  },
};
</script>

<style lang="scss" scoped>
#btnColumn {
  display: flex;
  align-items: flex-end;
  flex-direction: column;
  width: 100%;
  margin-top: 4em;
  .button {
    margin-top: 0;
    margin-right: 0;
    margin-bottom: 1em;
    width: 17vw;
    &.active {
      width: 15vw;
    }
  }
}

#sidebar {
  float: left;
  width: 22vw;
  height: 100vh;
  background: #00052f;
  display: flex;
  flex-direction: column;
  align-items: center;
}

h2 {
  color: white;
  padding: 2em;
}

.row {
  margin: 0 2em 0 2em;
}
</style>