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
            const url = `${dbUrl}/level1/level2`;
            t.is(database.refFromURL(url).toString(), url);
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


        test('limitToFirst/Last, start/endAt', async (t) => {
            if (!auth.currentUser) {
                await auth.signInAnonymously();
            }
            const ref = database.ref().child(Math.random().toString().split('.')[1]);
            const value = [1, 2, 3, 4, 5, 6];
            await ref.setValue(value);
            await t.wait('wait on limitToFirst', resolve => {
                ref.limitToFirst(2).once('value', async (snapshot) => {
                    t.is(await snapshot.numChildren(), 2, 'Number of children');
                    t.is(await snapshot.hasChildren(), true, 'Has children');
                    let count = 0;
                    await snapshot.forEach(async (child) => {
                        t.is(await child.val(), value[count], 'Snapshot val');
                        count++;
                    });
                    t.is(count, 2);
                    resolve();
                });
            });
            await t.wait('wait on limitToLast', resolve => {
                const limit = 3;
                ref.limitToLast(limit).once('value', async (snapshot) => {
                    t.is(await snapshot.numChildren(), limit, 'Number of children');
                    t.is(await snapshot.hasChildren(), true, 'Has children');
                    let count = 0;
                    const offset = value.length - limit;
                    t.deepEqual(
                        // I think this is right? Firebase will maintain indices?
                        [null, null, null, ...value.slice(offset)],
                        await snapshot.val());
                    await snapshot.forEach(async (child) => {
                        t.is(await child.val(), value[offset + count], 'Snapshot val');
                        count++;
                    });
                    t.is(count, limit);
                    resolve();
                });
            });
            await t.wait('wait on startAt', resolve => {
                const index = 2;
                ref.orderByValue().startAt(value[index]).once('value', async (snapshot) => {
                    t.is(await snapshot.numChildren(), value.length - index, 'Number of children');
                    t.is(await snapshot.hasChildren(), true, 'Has children');
                    let count = 0;
                    const offset = index;
                    t.deepEqual(
                        // I think this is right? Firebase will maintain indices?
                        [null, null, ...value.slice(index)],
                        await snapshot.val(),
                        'startAt snapshot.val()');
                    await snapshot.forEach(async (child) => {
                        t.is(await child.val(), value[offset + count], 'Snapshot val');
                        count++;
                    });
                    t.is(count, value.length - index);
                    resolve();
                });
            });
            await t.wait('wait on endAt', resolve => {
                const index = 2;
                ref.orderByValue().endAt(value[index]).once('value', async (snapshot) => {
                    t.is(await snapshot.numChildren(), index + 1, 'Number of children');
                    t.is(await snapshot.hasChildren(), true, 'Has children');
                    let count = 0;
                    t.deepEqual(value.slice(0, index + 1), await snapshot.val());
                    await snapshot.forEach(async (child) => {
                        t.is(await child.val(), value[count], 'Snapshot val');
                        count++;
                    });
                    t.is(count, index + 1);
                    resolve();
                });
            });
        });
    });
}
