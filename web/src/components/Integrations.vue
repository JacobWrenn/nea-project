<template>
  <div id="integrations" class="data">
    <div class="box">
      <div class="item" v-for="p in partners" :key="p.partnerid">
        <p id="name">{{ p.name }}</p>
        <p>{{ p.url }}</p>
      </div>
    </div>
    <div class="box">
      <div class="inputs">
        <input v-model="partner.name" type="text" placeholder="Name..." />
        <input v-model="partner.url" type="text" placeholder="URL..." />
        <input
          v-model="partner.accessToken"
          type="text"
          placeholder="Access token..."
        />
        <div class="button" @click="newPartner">New Partner</div>
      </div>
      <div class="inputs">
        <select v-model="service.partnerid">
          <option value="initial" disabled selected>Partner...</option>
          <option v-for="p in partners" :key="p.partnerid" :value="p.partnerid">
            {{ p.name }}
          </option>
        </select>
        <select v-model="service.locationid">
          <option value="initial" disabled selected>Location...</option>
          <option
            v-for="l in locations"
            :key="l.locationid"
            :value="l.locationid"
          >
            {{ l.name }}
          </option>
        </select>
        <input v-model="service.radius" type="number" placeholder="Radius..." />
        <div class="button" @click="newService">New Service Area</div>
      </div>
    </div>
  </div>
</template>

<script>
import api from "../api";

const initial = {
  partner: {
    name: null,
    description: "",
    url: null,
    accessToken: null,
  },
  service: {
    locationid: "initial",
    partnerid: "initial",
    radius: null,
  },
};

export default {
  data() {
    return {
      partners: [],
      locations: [],
      // Use spread syntax to copy object properties rather than just reference to the same object
      partner: { ...initial.partner },
      service: { ...initial.service },
    };
  },
  methods: {
    async load() {
      this.partners = await api.get("/admin/partners");
      this.locations = (await api.get("/booking/locations")).locations;
    },
    async newPartner() {
      await api.post("/admin/createPartner", {}, this.partner);
      this.partner = { ...initial.partner };
      this.load();
    },
    async newService() {
      await api.post("/admin/createService", {}, this.service);
      this.service = { ...initial.service };
      this.load();
      alert("Success!")
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

#name {
  margin-bottom: 1em;
}
</style>