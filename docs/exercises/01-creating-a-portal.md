# Adding a new mini app

Open the Android application (`./android`) in Android Studio, and then open `SuperApplication.kt`. You will see there are three Portals added to the `PortalManager`. 

The code to register a Portal with the `PortalManager` looks like this:

```kotlin
PortalManager.newPortal("time").setStartDir("time-tracking").create();
```

A Portal is responsible for loading a mini app within the super app. 

There are four mini apps contained within the `./web` directory in this project; the super app does not create a Portal for the Human Resources (`./web/human-resources`) mini app. 

Due to this, the super app crashes when the user tries to open the Human Resources mini app from the Dashboard view. Let's fix that!

## Bundling the mini app

Our first step is to copy the build files for the Human Resources mini app into the `src/main/assets` folder of the super app. 

Make sure you have built the Human Resources mini app by running the following command:

```bash
cd ./web/human-resources && npm run build && cd ../../
```

Take a look at `./android/app/build.gradle`. There are 3 pre-build tasks that copy the build files of a mini app into the super app. We need to add another task to copy the build files for the Human Resources mini app. 

Create a new `task` after Line 78:

```groovy
task CopyHumanResourcesWebAssets(type: Copy) {
    def webBuildFolder = '../../web/human-resources/dist'
    from webBuildFolder
    into layout.projectDirectory.dir("src/main/assets/human-resources")
}
```

Add an additional `preBuild.dependsOn()` function call after Line 81:

```groovy
preBuild.dependsOn(CopyHumanResourcesWebAssets)
```

## Creating the Portal instance

The super app now contains the build files for the Human Resources mini app. However, we do not have a Portal that will load it. We will register a new Portal to load the Human Resources mini app. 

Add the following code after Line 30 in `./android/app/src/main/java/io/ionic/superapp/SuperApplication.kt`:

```kotlin
// Human Resources Portal
PortalManager.newPortal("hr").setStartDir("human-resources").create()
```

Let's discuss what the code above is doing.

```kotlin
PortalManager
  .newPortal("hr") // Register a new Portal with PortalManager named "hr"
  .setStartDir("human-resources") // Load the mini app contained in src/main/assets/human-resources
  .create() // Create the Portal instance
```

Rebuild the application and try loading the Human Resources mini app; it should now work. However, navigating back from the Human Resources mini app to the super app's Dashboard view fails!

## What's next

In the next exercise, we will build a Capacitor plugin to communicate from the mini app to the super app. We will use the Capacitor plugin to fix the navigation problem.
