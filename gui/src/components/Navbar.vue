<template>
  <nav
    class="flex w-full h-min p-2 pl-3 bg-toyhouse-main-dark text-white justify-between items-center select-none"
  >
    <h1 class="hidden text-xl header md:block">
      <a href="https://toyhou.se" target="_blank">{{
        currentRoute.name === "Downloader" ? "TOYHOU.DL" : "TOYHOU.RF"
      }}</a>
    </h1>
    <div class="flex items-center mr-auto gap-5 md:ml-5">
      <router-link
        class="flex items-center gap-1 text-toyhouse-text-secondary transition duration-300 ease-out hover:text-white"
        to="/"
      >
        <DownloadIcon />
        Downloader
      </router-link>
      <router-link
        class="flex items-center gap-1 text-toyhouse-text-secondary transition duration-300 ease-out hover:text-white"
        to="/raffle"
      >
        <UserIcon />
        Raffle
      </router-link>
      <router-link
        class="flex items-center gap-1 text-toyhouse-text-secondary transition duration-300 ease-out hover:text-white"
        to="/participants"
      >
        <PeopleIcon />
        Participants
      </router-link>
    </div>

    <div class="flex gap-2 items-center">
      <RefreshIcon class="hover:cursor-pointer" @click="makeStatusQuery" />
      <div class="ml-auto flex items-center">
        <h1>App Status:</h1>
        <h1 v-if="status === 1" class="ml-2 text-green-600">Online</h1>
        <h1 v-else-if="status === 0" class="ml-2 text-red-600">Offline</h1>
        <h1 v-else class="ml-2">Fetching</h1>
      </div>
    </div>
  </nav>
</template>
<script setup lang="ts">
import DownloadIcon from "../assets/components/DownloadIcon.vue";
import PeopleIcon from "../assets/components/PeopleIcon.vue";
import UserIcon from "@/assets/components/UserIcon.vue";
import RefreshIcon from "@/assets/components/RefreshIcon.vue";
import { useRoute } from "vue-router";

import { computed, onMounted } from "vue";
import { makeStatusQuery } from "@/lib/health";
import { useStatusStore } from "@/stores/appStatus";

const statusStore = useStatusStore();

const status = computed(() => statusStore.status);
const currentRoute = useRoute();

onMounted(() => {
  makeStatusQuery();
});
</script>

<style scoped>
.header {
  transition: text-shadow 200ms ease-out;
}
.header:hover {
  text-shadow: 0 0 1px white, 0 0 8px white;
}
</style>
