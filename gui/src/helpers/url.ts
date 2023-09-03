export const getCharacterIdFromUrl = (url: string) => {
  let split = url.split("/");
  return split.slice(3).join("/");
};
