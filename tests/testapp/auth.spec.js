import suite from './test';

export default function makeSuite(app) {
    const auth = app.auth();
    return suite(test => {
        test('Auth onChange, login + logout', async (t) => {
            let onAuthStateChangedCalls = 0;
            const unsub = auth.onAuthStateChanged((user) => {
                if (onAuthStateChangedCalls === 2) {
                    t.truthy(user, '2nd onAuthStateChange user is set');
                    if (user) {
                        t.is(user.anonymous, true, '2nd onAuthStateChange');
                    }
                }
                if (onAuthStateChangedCalls === 3) {
                    t.falsy(user, '3rd onAuthStateChange');
                }

                onAuthStateChangedCalls++;
            });
            const user = await auth.signInAnonymously();
            t.is(user.anonymous, true);
            t.deepEqual(auth.currentUser, user);
            await auth.signOut();
            await t.delay();
            t.is(auth.currentUser, null, 'User null after logout');
            unsub();
            const countBefore = onAuthStateChangedCalls;
            await t.delay();
            await auth.signInAnonymously();
            await t.delay();
            t.is(countBefore, onAuthStateChangedCalls);
        });
    });
}
