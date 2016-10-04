import suite from './test';

export default function makeSuite(app) {
    const dbUrl = app.options.databaseURL;
    const database = app.database();
    const auth = app.auth();
    const base = String(Math.random()).split('.')[1];
    return suite(async (test) => {
        test('Keys and refs', async (t) => {
            t.is(database.ref(base).key(), base);
            t.is(database.ref(base).toString(), `${dbUrl}/${base}`);
            t.is(database.ref().key(), '');
            t.is(database.ref().toString(), dbUrl);
            t.is(database.ref(base).root().toString(), dbUrl);
            t.is(database.ref().child('test').toString(), `${dbUrl}/test`);
        });

        test('on child_added', async (t) => {
            if (!auth.currentUser) {
                await auth.signInAnonymously();
            }
            const now = new Date();
            const ref = database.ref().child(now.getTime().toString());
            const value = now.toString();
            const childAddedPromise = t.wait('child_added', resolve => {
                let called = 0;
                const unsub = ref.on('child_added', async (snapshot) => {
                    called++;
                    t.is(called, 1);
                    t.is(await snapshot.val(), value);
                    t.truthy(await snapshot.key());
                    unsub();
                    resolve();
                });
            });
            ref.push().setValue(value);
            await childAddedPromise;
            // This shouldn't trigger child_added above
            ref.push().setValue(value);
            await t.delay();
            const childAddedPromise2 = t.wait('child_added', resolve => {
                let called = 0;
                ref.once('child_added', async (snapshot) => {
                    called++;
                    t.is(called, 1);
                    t.is(await snapshot.val(), value);
                    t.truthy(await snapshot.key());
                    resolve();
                });
            });
            ref.push().setValue(value);
            await childAddedPromise2;
            // This shouldn't trigger child_added above
            ref.push().setValue(value);
            await t.delay();
        });

        test('on value', async (t) => {
            if (!auth.currentUser) {
                await auth.signInAnonymously();
            }
            const ref = database.ref().child(Math.random().toString().split('.')[1]);
            const value = Math.random().toString();
            const value2 = Math.random().toString();
            const value3 = Math.random().toString();
            const childAddedPromise = t.wait('wait on value', resolve => {
                let called = 0;
                const unsub = ref.on('value', async (snapshot) => {
                    called++;
                    t.is(called <= 3, true, 'Call count');
                    const v = await snapshot.val();
                    t.is(typeof v, 'object');
                    t.is(await snapshot.numChildren(), called, 'Number of children');
                    t.is(await snapshot.hasChildren(), true, 'Has children');
                    let count = 0;
                    await snapshot.forEach(async (child) => {
                        count++;
                        t.is(await child.val(), count === 1 ? value : value2,
                            'Snapshot val');
                        if (count === 2) {
                            // Stop iteration at 2
                            return true;
                        }
                    });
                    // We stop forEach at 2
                    t.is(count, Math.min(called, 2), 'snapshot forEach called count');
                    if (called === 3) {
                        unsub();
                        resolve();
                    }
                });
            });
            await ref.push().setValue(value);
            await t.delay();
            await ref.push().setValue(value2);
            await t.delay();
            await ref.push().setValue(value3);
            await childAddedPromise;
            await ref.push().setValue(value + ' LAST');
            await t.delay();
        });
    });
}
