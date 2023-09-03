<template>
  <KeepAlive>
    <main class="w-10/12 xl:w-7/12 flex flex-col h-5/6 justify-center m-auto">
      <CharacterCard />
      <IntroText />
    </main>
  </KeepAlive>
</template>
<script setup>
import CharacterCard from "@/components/CharacterCard/CharacterContainer.vue";
import IntroText from "@/components/IntroText/IntroText.vue";
</script>
