# Using the Dismiss plugin in a mini app

In the last coding exercise, we built a Capacitor plugin that communicates through a Portal. The "Time Tracking" mini app sends a message to the Android project that finishes the Android activity the Portal instance resides in. 

It does so by attaching a click event to the "< Dashboard" button:

```jsx
// ./web/time-tracking/src/components/TimeTrackingManager.tsx

<IonButton onClick={() => { dismissPlugin.dismiss(); }}>
  <IonIcon icon={chevronBack} />
  Dashboard
</IonButton>
```

We need to add click events to the "Human Resources" mini app.

## Coding challenge

There are two files in the "Human Resources" mini app that have a button with the "Dashboard" label:

- `./web/human-resources/src/components/HumanResourcesContractor.tsx`
- `./web/human-resources/src/components/HumanResourcesManager.tsx`

Using the code above as a guide, attach a click event to each file's "Dashboard" button. 

Note, you will need to add the following `import` statement to the top of each file:

```typescript
import { dismissPlugin } from "../super-app";
```

Once you are ready to test your changes first build the "Human Resources" mini app by running the following command:

```bash
cd ./web/human-resources && npm run build && cd ../..
```

Then build and run the Android application. If you are successful, you will be able to navigate back to the super app's Dashboard view by tapping the "< Dashboard" button in the "Human Resources" mini app.

## What's next

Congratulations! You have built and used your first Capacitor plugin to communicate through a Portal! 

Capacitor plugins can be used for any situation where you need to communicate between a mini app the Android application, including: error handling, analytics, and interacting with device peripherals.

Next, we will discuss how the super app knows which mini apps to show for the logged in user. 