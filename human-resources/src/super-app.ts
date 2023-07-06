import { getInitialContext } from "@ionic/portals";

export type Context = {
  supabase: {
    url: string;
    accessToken: string;
    refreshToken: string;
  };
  resourceId: number;
};

export const initialContext = getInitialContext<Context>()!.value!;
