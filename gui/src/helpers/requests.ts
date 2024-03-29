import { addPathToUrl, makeQueryFromOptions } from "./queryBuilder";

export const get = async (url: string) => {
  let res = await fetch(url);

  let json;
  try {
    json = await res.json();
  } catch (err) {
    console.log("Error while fetching", url);
    console.error(err);
    throw err;
  }

  return json;
};

export const getWithRetry = async (
  url: string,
  tries: number
): Promise<any> => {
  let triesLeft = tries;
  while (triesLeft > 0) {
    try {
      await get(url);
      return true;
    } catch {
      triesLeft -= 1;
      console.error(
        `Request to backend failed, retrying with ${triesLeft} tries left.`
      );
    }

    await new Promise((resolve) => setTimeout(resolve, 500));
  }

  throw "Could not reach backend!";
};

export const getCharacter = async (characterId: string) => {
  let url = addPathToUrl(`/character/${characterId}`);
  let json = get(url);
  return json;
};

export const getCharacterDetails = async (characterId: string) => {
  let url = addPathToUrl(`/character/${characterId}/details`);

  let json;
  try {
    json = get(url);
  } catch (err: any) {
    console.log("Error while fetching details", url);
    console.error(err);
    throw err;
  }
  return json;
};

export const getRaffleTickets = async (options: any) => {
  let url = makeQueryFromOptions(options);
  console.log(url);
  let json = get(url);
  return json;
};

export const getRaffleTicketsForAll = async (optsArray: any) => {
  let list: Record<string, any> = {};

  for (let idx = 0; idx < optsArray.length; idx++) {
    const opt = optsArray[idx];
    const res = await getRaffleTickets(opt);

    if (idx === 0) {
      list = res;
    } else {
      Object.keys(res).forEach((user) => {
        let userObj = res[user];

        if (Object.hasOwn(list, user)) {
          list[user].ticket_count += userObj.ticket_count;
        }
      });
    }
  }

  return list;
};

export const chunkArray = (arr: Array<any>, size: number) => {
  const mainArr = [];

  for (let i = 0; i < arr.length; i += size) {
    mainArr.push(arr.slice(i, i + size));
  }

  return mainArr;
};
