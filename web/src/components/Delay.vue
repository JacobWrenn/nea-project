<template>
  <div id="delay" class="data">
    <div class="box">
      <div class="item row" v-for="t in trains" :key="t.trainid">
        <p>Train {{ t.trainid }} to {{ t.name }}</p>
        <div class="button delete" @click="cancel(t.trainid)">Cancel</div>
        <input type="number" v-model="delayed" placeholder="Delay minutes...">
        <div class="button delete" @click="delay(t.trainid)">Append Delay</div>
      </div>
    </div>
  </div>
</template>

<script>
import api from "../api";

export default {
  data() {
    return {
      trains: [],
      delayed: null
    };
  },
  methods: {
    async load() {
      this.trains = await api.get("/admin/runningtrains");
    },
    async cancel(trainid) {
      await api.post("/admin/cancel", {}, { trainid });
      // Reload data on the page once a train has been cancelled.
      this.load();
    },
    async delay(trainid) {
      await api.post("/admin/appenddelay", {}, { trainid, delay: this.delayed });
      this.delayed = null;
      alert("Success!")
    }
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

input {
  width: 20%;
}
</style>