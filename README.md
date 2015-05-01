# A Watchkit fully working example with Core Data migration support

This is a follow up on my comments at ["WatchKit Mistakes"](http://realm.io/news/more-watchkit-mistakes/) thanks to  the guys at [Realm.io] (http://realm.io/) for the feature!

On my post I talk a bit on our mistakes at [Lifesum] (http://lifesum.com), when we did the first lunch of our Watch App, the biggest of them was moving our database from the usual Application Documents Folder to the new Appgroup Shared Folders.

Even through we manage to cover most of the cases on the migration, some users on old devices (iPhone 4S) had problems with the delay and the app ended up not lunching at all.

I this repository I have tried to cover most of the things you need to do to setup an smooth environment between your main app and your watchkit app, the repo includes:
- How to correctly run a database migration
- Support for importing bundled databases
- Using a Shared Framework between the main app and the WatchKit app
- Syncing data through Darwin Notifications

## Setup
1. Make sure to add your own Bundle Identifier and enable your own AppGroup ID through Xcode Capabilities
2. Modify ApplicationProperties.h/APP_GROUP_ID with your own ID
3. Modify ApplicationProperties.h/RUNNING_ON_APPGROUP macro if you want to test migrations.
