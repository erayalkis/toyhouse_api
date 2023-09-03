<template>
  <div>
    <h3 class="text-xl font-semibold">Toyhouse Raffle</h3>
    <hr class="my-2" />
    <h3 class="font-bold">Character Profile</h3>
    <div class="flex mt-2">
      <input
        v-model="url"
        placeholder="Profile URL"
        class="p-2 border border-toyhouse-border-primary outline-0 rounded-md rounded-r-none w-full indent-1"
      />
      <button
        class="bg-toyhouse-blue-primary text-white p-2 transition duration-300 ease-out rounded-md rounded-l-none hover:bg-toyhouse-button-secondary disabled:bg-toyhouse-button-secondary disabled:cursor-not-allowed"
        :disabled="!url.length"
        @click="load"
      >
        Load
      </button>
    </div>
  </div>
</template>
<script setup>
// import { makeQueryFromOptions } from "@/helpers/queryBuilder.js";
import { getCharacterDetails } from "../../../helpers/requests";
import { getCharacterIdFromUrl } from "../../../helpers/url";
import { useOptionsStore } from "../../../stores/optionsStore.ts";
import { useMessagesStore } from "../../../stores/messagesStore.ts";
import { storeToRefs } from "pinia";
import { ref } from "vue";

const url = ref("");
const messagesStore = useMessagesStore();
const optionsStore = useOptionsStore();

const { setError, clearError, setLoading, clearLoading } = messagesStore;
const { addCharacter } = optionsStore;
const { opts } = storeToRefs(optionsStore);

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
    console.error(err);
    setTimeout(() => {
      clearError();
    }, 1500);
  } finally {
    clearLoading();
    url.value = "";
  }
};
</script>
