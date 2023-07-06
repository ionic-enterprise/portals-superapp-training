import { registerPlugin } from "@capacitor/core";

interface LoggingPlugin {
  trackActivity(opts: { activityName: string }): Promise<{ success: boolean }>;
  logError(opts: { error: string }): Promise<void>;
}

export const loggingPlugin = registerPlugin<LoggingPlugin>("Logging");
