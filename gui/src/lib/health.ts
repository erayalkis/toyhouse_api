import { backendConfig } from "@/config/backendConfig";
import { useStatusStore } from "@/stores/appStatus";
import { useMessageStore } from "@/stores/message";
import { useMessagesStore } from "@/stores/messagesStore";
import { useErrorStore } from "@/stores/error";

export const makeStatusQuery = () => {
  const url = backendConfig.backendUrl;
  const statusStore = useStatusStore();
  const errorStore = useErrorStore();
  const messageStore = useMessageStore();
  const messagesStore = useMessagesStore();

  statusStore.setStatus(-1);
  console.log("fetching status...");
  fetch(`${url}/app_status`)
    .then(() => {
      console.log("app is up! :D");
      messagesStore.clearError();
      errorStore.clearError();
      statusStore.setStatus(1);
    })
    .catch(() => {
      console.log("app is down :(");
      // Check status store for code meanings
      statusStore.setStatus(0);
      messageStore.clearMessage();
      messagesStore.clearLoading();

      errorStore.setError("App is currently down! :(");
      messagesStore.setError("App is currently down! :(");
    });
};
