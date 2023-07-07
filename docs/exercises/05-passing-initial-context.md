# Sharing session information 

The super app we have been working with shares session information between the Android application code and mini apps. 

Session information is passed from the Android application to mini apps by using the Portals Plugin's [`initialContext`](https://ionic.io/docs/portals/choosing-a-communication#initial-context) ability.

## How it works

After the user logs into the super app, a private variable in the `DataManager` class gets set to the session:

```kotlin
private var session: UserSession? = null

suspend fun login(email: String, password: String): Boolean {
  try {
    client.gotrue.loginWith(Email) {
      this.email = email
      this.password = password
    }
  } catch (e: Exception) {
    if (e is BadRequestRestException) {
      return false
    }
  }

  session = client.gotrue.currentSessionOrNull()
  return session != null
}
```

The `AppActivity` is responsible for creating an activity that displays a Portal the user clicked on in the Dashboard view. It passes in the user's session as the initial context of the `PortalFragment` being created:

```kotlin
val initialContext = JSONObject()
initialContext.put("supabase", DataManager.instance.getSessionObject())

if(!eventId.isNullOrEmpty()) {
    initialContext.put("eventId", eventId)
}

portalFragment.setInitialContext(initialContext.toString())
```

Please note, `getSessionObject()` is a utility method that exposes the private `session` variable above.

A mini app can get `initialContext` passed from the Android application by calling `getInitialContext` from the `@ionic/portals` library. 

Take a look at `./web/human-resources/src/super-app.ts`:

```typescript
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
```

Notice that we are typing the information sent to the mini app as initial context.

The "Human Resources" mini app imports `initialContext` from `super-app.ts`. It uses the Supabase JS library to validate the session tokens and then stores a session object in component state:

```tsx
const [session, setSession] = useState<Session | null>();

useEffect(() => {
  supabase.auth
    .setSession({
      access_token: initialContext.supabase.accessToken,
      refresh_token: initialContext.supabase.refreshToken,
    })
    .then(({ data }) => {
      setSession(data.session);
    });

  const {
    data: { subscription },
  } = supabase.auth.onAuthStateChange((_event, session) => {
    setSession(session);
  });

  return () => subscription.unsubscribe();
}, []);
```

The component template renders the correct view; either the `manager` role view or the `contractor` role view:

```tsx
<IonApp>
  <IonReactRouter>
    <IonRouterOutlet>
      {session.user.app_metadata.app_role === "manager" ? (
        <HumanResourcesManager session={session} />
      ) : (
        <HumanResourcesContractor session={session} />
      )}
    </IonRouterOutlet>
  </IonReactRouter>
</IonApp>
```

The different communication mechanisms available to Portals allows us to add powerful functionality to super apps!

## What's next

The next exercise is our final one. We will refactor the Android application such that Portal creation (in `SuperApplication.kt`) is dynamic, and no longer needs to register all mini apps, even if the logged in user cannot access some of them.