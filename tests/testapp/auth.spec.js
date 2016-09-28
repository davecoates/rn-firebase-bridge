import suite from './test';

export default function makeSuite(app) {
    const auth = app.auth();
    return suite(test => {
        test('Auth', async (t) => {
            let onAuthStateChangedCalls = 0;
            const unsub = auth.onAuthStateChanged((user) => {
                if (onAuthStateChangedCalls === 0) {
                    t.truthy(user);
                    if (user) {
                        t.is(user.anonymous, true);
                    }
                }
                if (onAuthStateChangedCalls === 1) {
                    t.falsy(user);
                }

                onAuthStateChangedCalls++;
            });
            const user = await auth.signInAnonymously();
            t.is(user.anonymous, true);
            t.deepEqual(auth.currentUser, user);
            await auth.signOut();
            unsub();
            t.is(onAuthStateChangedCalls, 2);
        });
    });
}
