export interface Notification {
  title: string;
  body: string;
  type: string;
  data: Record<string, any> | null;
}
