<template>
  <div class="pt-5">
    <h3 class="text-sm text-blue-500 text-center">{{ loadingMessage }}</h3>
    <h3 class="text-sm text-red-500 text-center">{{ errorMessage }}</h3>
  </div>
</template>
<script setup>
import { useMessagesStore } from "@/state/messagesStore";
const messagesStore = useMessagesStore();
import { storeToRefs } from "pinia";
const { loadingMessage, errorMessage } = storeToRefs(messagesStore);
</script>
