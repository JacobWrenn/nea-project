<template>
  <div id="trains" class="data">
    <div class="box">
      <div class="item" v-for="train in traction" :key="train.tractionid">
        <div class="row">
          <p>Class {{ train.tractionid }}</p>
          <p>Carbon Per Mile {{ train.carbonpermile }}kg</p>
        </div>
        <p v-for="c in train.capacity" :key="c.goodtype">
          Can take: {{ c.number }} {{ c.goodtype.toLowerCase() }}
        </p>
      </div>
    </div>
    <div class="box">
      <div class="inputs">
        <input
          v-model="train.class"
          type="text"
          placeholder="Class number..."
        />
        <input
          v-model="train.cpm"
          type="number"
          placeholder="Carbon per mile..."
        />
        <div class="button" @click="newTrain">New Train</div>
      </div>
      <div class="inputs">
        <input v-model="type.type" type="text" placeholder="Good type..." />
        <input v-model="type.units" type="text" placeholder="Units..." />
        <div class="button" @click="newType">New Good Type</div>
      </div>
      <div class="inputs">
        <select v-model="capacity.class">
          <option value="initial" disabled selected>Class number...</option>
          <option
            v-for="t in traction"
            :key="t.tractionid"
            :value="t.tractionid"
          >
            {{ t.tractionid }}
          </option>
        </select>
        <select v-model="capacity.type">
          <option value="initial" disabled selected>Good type...</option>
          <option v-for="t in types" :key="t.goodtype" :value="t.goodtype">
            {{ t.goodtype }}
          </option>
        </select>
        <input
          v-model="capacity.number"
          type="number"
          placeholder="Number..."
        />
        <div class="button" @click="newCapacity">New Capacity</div>
      </div>
    </div>
  </div>
</template>

<script>
import api from "../api";

const initial = {
  train: {
    class: null,
    cpm: null,
  },
  type: {
    type: null,
    units: null,
  },
  capacity: {
    class: "initial",
    type: "initial",
    number: null,
  },
};

export default {
  data() {
    return {
      traction: [],
      types: [],
      train: {...initial.train},
      type: {...initial.type},
      capacity: {...initial.capacity},
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
      this.types = (await api.get("/booking/types")).types;
    },
    async newTrain() {
      await api.post(
        "/admin/createtraction",
        {},
        { id: this.train.class, cpm: this.train.cpm }
      );
      this.train = {...initial.train};
      this.load();
    },
    async newType() {
      await api.post(
        "/admin/createtype",
        {},
        {
          type: this.type.type,
          description: this.type.type,
          units: this.type.units,
        }
      );
      this.type = {...initial.type};
      this.load();
    },
    async newCapacity() {
      await api.post(
        "/admin/createcapacity",
        {},
        {
          tractionid: this.capacity.class,
          type: this.capacity.type,
          number: this.capacity.number,
        }
      );
      this.capacity = {...initial.capacity};
      this.load();
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
</style>