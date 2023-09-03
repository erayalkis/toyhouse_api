import { createRouter, createWebHashHistory } from "vue-router";

const routes = [
  { path: "/downloader", component: DownloaderView },
  { path: "/raffle", component: RaffleView },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

export default router;
