<template>
  <nav
    class="flex w-full h-min p-2 pl-3 bg-toyhouse-main-dark text-white justify-between items-center select-none"
  >
    <h1 class="hidden text-xl md:block">
      <a href="https://toyhou.se" target="_blank">TOYHOU.RF</a>
    </h1>
    <div class="flex items-center mr-auto gap-5 md:ml-5">
      <router-link
        class="flex items-center gap-1 text-toyhouse-text-secondary transition duration-300 ease-out hover:text-white"
        to="/"
      >
        <HomeIcon />
        Home
      </router-link>
      <router-link
        class="flex items-center gap-1 text-toyhouse-text-secondary transition duration-300 ease-out hover:text-white"
        to="/participants"
      >
        <PeopleIcon />
        Participants
      </router-link>
    </div>
    <AppStatus />
  </nav>
</template>
<script setup>
import HomeIcon from "../../assets/components/HomeIcon.vue";
import PeopleIcon from "../../assets/components/PeopleIcon.vue";
import AppStatus from "./AppStatus.vue";
</script>
