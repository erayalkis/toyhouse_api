export const getCharacterIdFromUrl = (url) => {
  let split = url.split("/");
  return split.slice(3).join("/");
};
