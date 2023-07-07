# Communicating through a Portal

There are two ways to communicate between a mini app and the Android application:

1. Using the built-in [Portals Plugin](https://ionic.io/docs/portals/choosing-a-communication#the-portals-plugin)
2. Using [Capacitor plugins](https://ionic.io/docs/portals/choosing-a-communication#capacitor-plugins)

In this coding exercise, we will build a Capacitor plugin to navigate back from a mini app to the Dashboard view of the Android application.

## Capacitor plugin review

Capacitor plugins allow web applications (mini apps) to communicate with different native platforms (Android application).

- A common API contract is developed using TypeScript. 
- Platform-specific implementations are written, aligned with the API contract. 
- The web application registers the API contract as a Capacitor plugin.
- The platform-specific implementation is registered to one-or-many Portal instances.  

When these steps are complete, web applications can call methods on the API contract. When they are called, the methods call the platform-specific implementation and receive output from the call, if needed.

Let's define the API contract for this Capacitor plugin. We will call this plugin `DismissPlugin`, because it will dismiss the mini app and return the user back to the Dashboard view.

Modify `./web/human-resources/src/super-app.ts` to match the code block below:

```diff
+ import { registerPlugin } from "@capacitor/core";
  import { getInitialContext } from "@ionic/portals";

  export type Context = {
    resourceId: number;
  };

+ interface DismissPlugin {
+   dismiss(): Promise<void>;
+ }

+ export const dismissPlugin = registerPlugin<DismissPlugin>("Dismiss", {});
  export const initialContext = getInitialContext<Context>()!.value!;
```

In the code above, we are defining the plugin's API as well as registering the plugin for the mini app to use.

## Add the Android implementation code

Create a new file `android/app/src/main/java/io/ionic/superapp/ui/plugins/DismissPlugin.kt`. Populate the file with the following code:

```kotlin
package io.ionic.superapp.ui.plugins

import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

@CapacitorPlugin(name = "Dismiss")
class DismissPlugin(val callback: () -> Unit): Plugin() {

    @PluginMethod
    fun dismiss(call: PluginCall) {
        callback()
        call.resolve()
    }
}
```

## Register the plugin to each Portal instance

Open `android/app/src/main/java/io/ionic/superapp/ui/app/AppActivity.kt` and look for the if block starting with `if(portalName != null)`. We will want to add the Dismiss plugin after we set `val portal: Portal`:

```diff
if(portalName != null) {
  val portal: Portal = PortalManager.getPortal(portalName)
+ portal.addPluginInstance(DismissPlugin { finish() })
  val portalFragment = PortalFragment(portal)
  val initialContext = JSONObject()
  initialContext.put("supabase", DataManager.instance.getSessionObject())
}
```

Build and run the application and navigate to the "Time Tracking" mini app. You should be able to navigate back to the Dashboard view by pressing the "< Dashboard" button. Now open the "Human Resources" and try to navigate back the same way. Notice that it is still broken...do you know why? 

## What's next

The "< Dashboard" button on the Human Resources mini app needs to call `dismissPlugin.dismiss()`. We will fix that next.