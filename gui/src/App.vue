<template>
  <div class="w-screen h-screen">
    <Navbar />
    <router-view></router-view>
    <NotifModal />
  </div>
</template>

<script setup lang="ts">
import Navbar from "./components/Navbar.vue";
import NotifModal from "./components/NotifModal.vue";
</script>
