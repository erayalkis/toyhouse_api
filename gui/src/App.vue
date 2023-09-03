<template>
  <div class="w-screen h-screen">
    <Navbar />
    <router-view></router-view>
  </div>
</template>

<script setup lang="ts">
import Navbar from "./components/Navbar.vue";
</script>
