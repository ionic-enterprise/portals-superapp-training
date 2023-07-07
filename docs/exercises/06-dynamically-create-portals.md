# Dynamic Portal registration

Recall that the super app creates and registers a Portal for each mini app that could _possibly_ be navigated to:

```kotlin
// ./android/app/src/main/java/io/ionic/superapp/SuperApplication.kt

// Time Tracking Portal
PortalManager.newPortal("time")
    .setStartDir("time-tracking")
    .create()

// People Perks Portal
PortalManager.newPortal("perks")
    .setStartDir("perks")
    .create()

// CRM Portal
PortalManager.newPortal("crm")
    .setStartDir("crm")
    .create()

// Human Resources Portal
PortalManager.newPortal("hr")
    .setStartDir("human-resources")
    .create()
```

There are two inefficiencies with that approach:

1. We are creating and registering a Portal instance for mini apps that the user may not be able to see.
2. As more mini apps are added, we need to explicitly define them.

Let's refactor this code so that Portal creation and registration is dynamic. Only Portals for mini apps the logged in users can access will be created.

Go ahead and delete the code above. When you are finished, `SuperApplication.kt` should look like this:

```kotlin
package io.ionic.superapp
import android.app.Application
import io.ionic.portals.PortalManager
import io.ionic.superapp.data.DataManager
import java.util.*
import kotlin.collections.HashMap

class SuperApplication : Application() {
  override fun onCreate() {
    super.onCreate()

    // Register Portals
    PortalManager.register("YOUR_PORTALS_KEY")
  }
}
```

You should replace `"YOUR_PORTALS_KEY"` with your actual Portals key from the Ionic dashboard.

## Update the dashboard

The code to create and register Portals has been removed from the main entry-point of the super app, let's re-integrate it in a place where we get the list of mini apps the current user has access to. 

Open the `DashboardActivity` (`./android/app/src/main/java/io/ionic/superapp/ui/dashboard/DashboardActivity.kt`). This file has access to the list of mini apps the current user has access to! We can refactor the coroutine launch block starting on Line 83 to create and register Portals _only_ for the mini apps the current user can access:

```kotlin
CoroutineScope(Dispatchers.Main).launch {
  val apps = DataManager.instance.getApps()
  for (app in apps) {
    PortalManager.newPortal(app.id).create()
  }

  delay(800L)
  dashboardViewModel.update()
}
```

## Update the build gradle file

Note the following code from the section above:

```kotlin
PortalManager.newPortal(app.id).create()
```

We no longer call `setStartDir()`. When `setStartDir()` is excluded, the `PortalManager` will look for the mini app's build files in `src/main/assets/{app.id}`.

For example, `PortalManager.newPortal("hr").create()` expects the build files for the "Human Resources" mini app to be in `src/main/assets/hr`. However, the `PortalManager`'s assumption is incorrect based on the task created in `android/app/build.gradle`:

```groovy
task CopyHRWebAssets(type: Copy) {
  def webBuildFolder = '../../web/human-resources/dist'
  from webBuildFolder
  into layout.projectDirectory.dir("src/main/assets/human-resources")
}
```

This is an easy fix. Make the following changes to `android/app/build.gradle`:

```diff
task CopyHRWebAssets(type: Copy) {
  def webBuildFolder = '../../web/human-resources/dist'
  from webBuildFolder
- into layout.projectDirectory.dir("src/main/assets/human-resources")
+ into layout.projectDirectory.dir("src/main/assets/hr")
}
```

We also need to make a change to `CopyTimeWebAssets`:

```diff
task CopyTimeWebAssets(type: Copy) {
  def webBuildFolder = '../../web/time-tracking/dist'
  from webBuildFolder
- into layout.projectDirectory.dir("src/main/assets/time-tracking")
+ into layout.projectDirectory.dir("src/main/assets/time")
}
```

Once this is complete, rebuild the application and run it. The super app should continue functioning as is. However - as developers - we know about the enhancements made by refactoring how we create and register Portals!

## Congratulations! 

You have added a new mini app into the super app, created communication through a Portal (from a mini app to the Android app, and from the Android app to a mini app), learned how to show mini apps based on user role and share session information, and then refactored the existing code to strategically create and register Portals based on the current user's needs. 
