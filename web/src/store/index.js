import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    "loggedIn": false,
    "tab": "",
  },
  // Mutations will update state and inform all components of a change. This allows the tab content that is being displayed to instantly change when a new tab is clicked.
  mutations: {
    setLogIn(state, bool) {
      state.loggedIn = bool
    },
    setTab(state, tab) {
      state.tab = tab
    },
  },
  actions: {
  },
  modules: {
  }
})
