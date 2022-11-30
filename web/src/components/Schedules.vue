<template>
  <div id="schedules" class="data">
    <div class="box">
      <div class="inputs">
        <input
          type="text"
          v-model="schedule.dayofweek"
          placeholder="Day of week..."
        />
        <div class="row">
          <label>Start date:</label
          ><input type="date" v-model="schedule.start" />
        </div>
        <div class="row">
          <label>End date:</label><input type="date" v-model="schedule.end" />
        </div>
        <select v-model="schedule.type">
          <option value="initial" disabled selected>Traction type...</option>
          <option
            v-for="t in traction"
            :key="t.tractionid"
            :value="t.tractionid"
          >
            {{ t.tractionid }}
          </option>
        </select>
      </div>
      <div class="inputs" v-for="int in stopinputs" :key="int">
        <select v-model="stops[int].locationid">
          <option value="initial" disabled selected>Location...</option>
          <option
            v-for="l in locations"
            :key="l.locationid"
            :value="l.locationid"
          >
            {{ l.name }}
          </option>
        </select>
        <input
          type="number"
          v-model="stops[int].distance"
          placeholder="Distance..."
        />
        <div class="row">
          <label>Time:</label><input type="time" v-model="stops[int].time" />
        </div>
      </div>
      <div class="inputs addstop">
        <div class="button" @click="addStop">Add Stop</div>
      </div>
      <div class="inputs">
        <div class="button" @click="newSchedule">Save Schedule</div>
      </div>
    </div>
    <div class="box">
      <div class="inputs">
        <input type="text" v-model="location.name" placeholder="Name..." />
        <input
          type="text"
          v-model="location.hub"
          placeholder="Hub? (true or false)"
        />
        <input type="number" v-model="location.lat" placeholder="Latitude..." />
        <input
          type="number"
          v-model="location.long"
          placeholder="Longitude..."
        />
        <div class="button" @click="newLocation">New Location</div>
      </div>
    </div>
  </div>
</template>

<script>
import api from "../api";

const initial = {
  schedule: {
    dayofweek: null,
    type: "initial",
    start: null,
    end: null,
  },
  location: {
    name: null,
    hub: null,
    lat: null,
    long: null,
  },
  stop: {
    locationid: "initial",
    distance: null,
    time: null,
  },
};

export default {
  data() {
    return {
      traction: [],
      locations: [],
      stopinputs: [0],
      schedule: { ...initial.schedule },
      location: { ...initial.location },
      stops: [{ ...initial.stop }],
    };
  },
  methods: {
    async load() {
      const data = await api.get("/admin/traction");
      for (let traction of data) {
        traction.capacity = await api.get("/admin/capacity", {
          tractionid: traction.tractionid,
        });
      }
      this.traction = data;
      this.locations = (await api.get("/booking/locations")).locations;
    },
    async newLocation() {
      await api.post(
        "/admin/createlocation",
        {},
        {
          name: this.location.name,
          lat: this.location.lat,
          long: this.location.long,
          hub: this.location.hub,
        }
      );
      this.location = { ...initial.location };
      this.load();
      alert("Success!")
    },
    async newSchedule() {
      await api.post(
        "/admin/createschedule",
        {},
        {
          day: this.schedule.dayofweek,
          tractionid: this.schedule.type,
          start: this.schedule.start,
          end: this.schedule.end,
          stops: this.stops,
        }
      );
      this.schedule = { ...initial.schedule };
      this.stopinputs = [0];
      this.stops = [{ ...initial.stop }];
      this.load();
      alert("Success!")
    },
    addStop() {
      this.stops.push({ ...initial.stop });
      this.stopinputs.push(this.stopinputs[this.stopinputs.length - 1] + 1);
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
      margin-right: 4em;
    }
  }
}

.addstop {
  margin-bottom: 2em;
  margin-top: -3em;
}

.row {
  justify-content: flex-start;
  width: 100%;
  label {
    margin-right: 1em;
  }
}
</style>