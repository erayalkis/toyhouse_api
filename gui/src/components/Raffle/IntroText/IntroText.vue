<template>
  <div
    class="flex flex-col mt-5 text-toyhouse-dark border border-toyhouse-primary-border rounded-sm"
  >
    <template v-for="(text, idx) in textContent" :key="idx">
      <div class="flex w-full">
        <div
          class="bg-toyhouse-bg-secondary w-min pl-6 pr-3 text-right text-sm"
        >
          {{ idx + 1 }}
        </div>
        <div class="pl-1 text-toyhouse-primary-500 opacity-70">
          <h1>{{ text }}</h1>
        </div>
      </div>
    </template>
  </div>
</template>
<script setup>
import { textContent } from "./textContent";
</script>
