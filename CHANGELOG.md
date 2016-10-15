### Release 0.1.0

  * Support multiple apps.
  * API changed to closer match web SDK - not backwards compatible. You must now
  access all methods from an app instance or shortcut methods.
  * Add `User` class
    * Includes new methods `delete`, `getToken`, `link`, `reauthenticate`, `reload`, `sendEmailVerification`,
    `unlink`, `updateEmail`, `updatePassword`, `updateProfile`
  * Add `Database` class with `goOnline`, `goOffline`, `setPersistenceEnabled`.
  * Add `fetchProvidersForEmail`, `sendPasswordResetEmail`, `signInWithCustomToken`
  * `getCurrentUser()`` method no longer available; access `currentUser` from auth
  instance instead.

### Release 0.0.11

  * Add currentUser
  * Add getCurrentUser() [@Victoor #17]
  * Fix incorrect / missing flow types

### Release 0.0.10

  * Add auth signOut() function
