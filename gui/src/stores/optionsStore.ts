import { defineStore } from "pinia";
import { Ref, computed, ref } from "vue";

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

  const opts: Ref<Array<any>> = ref([]);
  const loadedMain = computed(() => opts.value.length > 0);

  const addCharacter = (character: any) => {
    if (characterAlreadyAdded(character)) return;

    let newOpts = Object.assign({}, defaultOptions);
    newOpts.character = character;

    opts.value.push(newOpts);
  };

  const resetCharacter = (character: any) => {
    let characterId = character.id;

    let characterIdx = opts.value.findIndex(
      (opt: any) => opt.character.id === characterId
    );

    let newOpts = defaultOptions;
    newOpts.character = character;

    opts.value[characterIdx] = newOpts;
  };

  const updateCharacter = (character: any) => {
    let characterId = character.id;

    let characterIdx = opts.value.findIndex(
      (opt: any) => opt.character.id === characterId
    );

    opts.value[characterIdx] = character;
  };

  const removeCharacter = (character: any) => {
    let characterId = character.id;

    opts.value = opts.value.filter(
      (opt: any) => opt.character.id !== characterId
    );
  };

  const characterAlreadyAdded = (character: any) => {
    return opts.value.some((opt: any) => opt.character.id === character.id);
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
