<template>
  <div class="my-2">
    <div class="items-center gap-1">
      <h1 class="text-lg">Included characters:</h1>
      <div class="flex">
        <input
          v-model="url"
          placeholder="Profile URL"
          class="p-2 border border-toyhouse-border-primary outline-0 rounded-md rounded-r-none w-full indent-1"
        />
        <button
          class="bg-toyhouse-blue-primary text-white p-2 transition duration-300 ease-out rounded-md rounded-l-none hover:bg-toyhouse-blue-secondary"
          @click="load"
        >
          Load
        </button>
      </div>
      <CharacterFormMessages />
      <CharacterFormOptionsIncludedList />
    </div>
  </div>
</template>
<script setup>
import { getCharacterDetails } from "@/helpers/requests";
import { getCharacterIdFromUrl } from "@/helpers/url";
import { useMessagesStore } from "@/state/messagesStore";
import { useOptionsStore } from "@/state/optionsStore.js";
import { storeToRefs } from "pinia";
import { ref } from "vue";
import CharacterFormMessages from "./CharacterFormMessages.vue";
import CharacterFormOptionsIncludedList from "./CharacterOptionsIncludedList.vue";

const url = ref("");
const messagesStore = useMessagesStore();
const optionsStore = useOptionsStore();

const { setError, setLoading, clearLoading, clearError } = messagesStore;
const { addCharacter } = optionsStore;
let { opts } = storeToRefs(optionsStore);

const load = async () => {
  setLoading("Loading your character...");
  let id = getCharacterIdFromUrl(url.value);

  await loadCharacter(id);
};

const ensureCharacterUnique = (id) => {
  let alreadyExists = characterExistsInOpts(id);
  if (alreadyExists) {
    throw Error("Character already loaded!");
  }
};

const characterExistsInOpts = (id) => {
  console.log(opts.value, id);
  return opts.value.some((opt) => opt.character.id === id);
};

const loadCharacter = async (id) => {
  try {
    ensureCharacterUnique(id);

    let details = await getCharacterDetails(id);
    if (details.name === "") {
      throw Error("Something went wrong while loading your character!");
    }
    addCharacter(details);
  } catch (err) {
    setError(err);
    setTimeout(() => {
      clearError();
    }, 1500);
    console.error(err);
  } finally {
    clearLoading();
    url.value = "";
  }
};
</script>
