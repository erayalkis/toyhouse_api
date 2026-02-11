import { API_URL } from "./constants";

// Helper to join URL parts without double slashes
const joinUrl = (base: string, path: string) => {
  const cleanBase = base.replace(/\/+$/, ''); // Remove trailing slashes
  const cleanPath = path.replace(/^\/+/, ''); // Remove leading slashes
  return `${cleanBase}/${cleanPath}`;
};

export const addPathToUrl = (path: string) => joinUrl(API_URL, path);

export const makeQueryFromOptions = (opts: any) => {
  let url = joinUrl(API_URL, `/raffle/${opts.character.id}`);
  let queryStr = "?";

  if (opts.must_comment) {
    queryStr += `&must_comment=true&comment_ticket_count=${opts.comment_points}`;
  }

  if (opts.must_subscribe) {
    queryStr += `&must_subscribe=true&subscribe_ticket_count=${opts.subscribe_points}`;
  }

  queryStr += `&fav_ticket_count=${opts.favorite_points}`;

  return url + queryStr;
};
