export interface Notification {
  title: string;
  body: string;
  data: Record<string, any> | null;
}
