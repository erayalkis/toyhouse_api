import { defineStore } from "pinia";
import { computed, ref } from "vue";

export const useOptionsStore = defineStore("options", () => {
  const defaultOptions = {
    character: {
      name: "",
      image: "",
      owner: {
        name: "",
        profile: "",
      },
    },
    must_comment: false,
    comment_points: 1,
    must_subscribe: false,
    subscribe_points: 1,
    must_favorite: true,
    favorite_points: 1,
  };

  const opts = ref([]);
  const loadedMain = computed(() => opts.value.length > 0);

  const addCharacter = (character) => {
    if (characterAlreadyAdded(character)) return;

    let newOpts = Object.assign({}, defaultOptions);
    newOpts.character = character;

    opts.value.push(newOpts);
  };

  const resetCharacter = (character) => {
    let characterId = character.id;

    let characterIdx = opts.value.findIndex(
      (opt) => opt.character.id === characterId
    );

    let newOpts = defaultOptions;
    newOpts.character = character;

    opts.value[characterIdx] = newOpts;
  };

  const updateCharacter = (character) => {
    let characterId = character.id;

    let characterIdx = opts.value.findIndex(
      (opt) => opt.character.id === characterId
    );

    opts.value[characterIdx] = character;
  };

  const removeCharacter = (character) => {
    let characterId = character.id;

    opts.value = opts.value.filter((opt) => opt.character.id !== characterId);
  };

  const characterAlreadyAdded = (character) => {
    return opts.value.some((opt) => opt.character.id === character.id);
  };

  return {
    opts,
    loadedMain,
    addCharacter,
    resetCharacter,
    updateCharacter,
    removeCharacter,
  };
});
