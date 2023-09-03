export const API_URL =
  process.env.NODE_ENV === "development"
    ? "http://localhost:8081"
    : "https://toyhouse-api.onrender.com";
