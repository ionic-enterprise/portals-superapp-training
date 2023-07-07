# Loading different mini apps for different users

Log into the application using the following account:

- Username: `tanya@supernova.com`
- Password: `il0vedogs`

Notice that this account has access to three mini apps: "Human Resources", "People Perks", and "Time Tracking". 

Log out of the application and log in using this account:

- User: `trevor@supernova.com`
- Password: `il0vedogs`

This account has access to two mini apps: "People Perks" and "Customer Relations".

Users in this super app are assigned a `role` and each mini app is available to users that have a particular role. For instance, `tanya@supernova.com` has the `manager` role. Only users with a `contractor` or `manager` role have access to the "Human Resources" mini app. Conversely, `trevor@supernova.com` has the `sales` role. Only users with the `sales` role can access the "Customer Relations" mini app. 

## How this works

The mapping between mini apps and the roles that can access them exist in the Supabase backend. Open [http://localhost:54323/project/default/editor](http://localhost:54323/project/default/editor) in the browser and select the "apps" table. Here you will find permission mapping to see which roles can access which mini app.

The super app accesses the backend through the `DataManager` class (`./android/app/src/main/java/io/ionic/superapp/data/DataManager.kt`). It gets the list of apps the current user has access to:

```kotlin
suspend fun getApps(): List<App> {
  val appList = mutableListOf<App>()

  val userId = session?.user?.id
  if (userId != null) {
    return client.postgrest.rpc("get_apps", Employee(employee_id = userId)).decodeList()
  } else {
    logout()
  }

  return appList
}
```

The `DashboardViewModel` class calls `DataManager.getApps()` and passes it to the `DashboardActivity` class. `DashboardActivity` then iterates over the list of apps and renders each one as a row item on the Dashboard view:

```kotlin
dashboardViewModel.appList.observe(this, Observer {
    appSkeleton.showOriginal()
    appList.adapter = AppAdapter(it, this)
})
```

You can edit rows in the "apps" table to grant or deny access to any mini app to any role by editing the `role_access` column. Make an edit so the `manager` role has access to the "Customer Relations" mini app. Then log out of the application, and log in using `tanya@supernova.com`. This account should now have access to all 4 mini apps.

## What's next

Each mini app in the super app is aware of who the logged in user is. You can test this by opening the "Time Tracking" app once as `jeremiah@supernova.com` and then as `tanya@supernova.com`. Notice that `tanya@supernova.com` has the ability to approve PTO requests, while `jeremiah@supernova.com` can not. The ability to approve PTO requests is enabled for users with the `manager` role. 

But, how does the mini app know that the user has a `manager` role? We will look into that next.