<template>
  <div id="users" class="data">
    <div class="box">
      <div class="item row" v-for="u in users" :key="u.username">
        <p>Username: {{ u.username }}</p>
        <div class="button delete" @click="removeStaff(u.username)">Delete</div>
      </div>
    </div>
    <div class="box">
      <div class="inputs">
        <input v-model="staff.username" type="text" placeholder="Username..." />
        <input v-model="staff.password" type="text" placeholder="Password..." />
        <div class="button" @click="newStaff">New Staff</div>
      </div>
    </div>
  </div>
</template>

<script>
import api from "../api";

const initial = {
  staff: {
    username: null,
    password: null
  },
};

export default {
  data() {
    return {
      users: [],
      staff: { ...initial.staff },
    };
  },
  methods: {
    async load() {
      this.users = await api.get("/admin/staff");
    },
    async newStaff() {
      await api.post("/admin/createstaff", {}, this.staff);
      this.staff = { ...initial.staff };
      this.load();
    },
    async removeStaff(username) {
      // confirm is a built-in method available in all browsers
      if (confirm(`Are you sure you want to delete ${username}?`)) {
        await api.delete("/admin/staff", {}, { username });
        this.load();
      }
    },
  },
  mounted() {
    this.load();
  },
};
</script>

<style lang="scss" scoped>
.row {
  margin-bottom: 1em;
  p {
    &:first-child {
      margin-top: auto;
      margin-bottom: auto;
      margin-right: 4em;
    }
  }
}

.delete {
  color: white;
  background: red;
  font-size: 1em;
  margin: 1em;
  padding: 1em;
  border-radius: 0.5em;
}

.item {
  padding: 0.5em;
}
</style>