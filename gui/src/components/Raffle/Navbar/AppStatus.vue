<template>
  <div class="flex justify-between text-xl">
    <h3 class="hidden mr-2 text-toyhouse-text-secondary md:block">
      App Status:
    </h3>
    <h3
      :class="{
        'text-green-600': isOnline,
        'text-red-600': !isFetching && !isOnline,
      }"
    >
      {{ isFetching ? "..." : isOnline ? "Online" : "Offline" }}
    </h3>
  </div>
</template>
<script setup lang="ts">
import { onMounted, ref } from "vue";

const isOnline = ref(false);
const isFetching = ref(true);

onMounted(async () => {
  fetch("https://toyhouse-api.onrender.com/app_status").then(async (res) => {
    console.log(await res.json());
    if (res.ok) {
      isOnline.value = true;
    }
    isFetching.value = false;
  });
});
</script>
