import { defineStore } from "pinia";
import { ref } from "vue";

export const useMessagesStore = defineStore("messages", () => {
  const loadingMessage = ref("");
  const errorMessage = ref("");

  const setLoading = (str: string) => (loadingMessage.value = str);
  const setError = (str: string) => (errorMessage.value = str);
  const clearLoading = () => (loadingMessage.value = "");
  const clearError = () => (errorMessage.value = "");

  return {
    loadingMessage,
    errorMessage,
    setLoading,
    setError,
    clearLoading,
    clearError,
  };
});
