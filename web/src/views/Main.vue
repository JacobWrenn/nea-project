<template>
  <div id="main">
    <Sidebar></Sidebar>
    <Users v-if="tab == 'users'"></Users>
    <Trains v-if="tab == 'trains'"></Trains>
    <Schedules v-if="tab == 'schedules'"></Schedules>
    <Integrations v-if="tab == 'integrations'"></Integrations>
    <Delay v-if="tab == 'delay'"></Delay>
  </div>
</template>

<script>
import Sidebar from "../components/Sidebar.vue";
import Users from "../components/Users.vue";
import Trains from "../components/Trains.vue";
import Schedules from "../components/Schedules.vue";
import Integrations from "../components/Integrations.vue";
import Delay from "../components/Delay.vue"
import { mapState } from "vuex";

export default {
  components: {
    Sidebar,
    Users,
    Trains,
    Schedules,
    Integrations,
    Delay
  },
  computed: mapState(["tab"])
};
</script>

<style lang="scss" scoped>
</style>