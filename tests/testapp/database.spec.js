import suite from './test';

export default function makeSuite(app) {
    const dbUrl = app.options.databaseURL;
    const database = app.database();
    const auth = app.auth();
    const base = String(Math.random()).split('.')[1];
    return suite(test => {
        test('Database test', async (t) => {
            t.is(database.ref(base).key(), base);
            t.is(database.ref(base).toString(), `${dbUrl}/${base}`);
            t.is(database.ref().key(), '');
            t.is(database.ref().toString(), dbUrl);
            t.is(database.ref(base).root().toString(), dbUrl);
            t.is(database.ref().child('test').toString(), `${dbUrl}/test`);
        });
        test('Authenticated database test', async (t) => {
            const user = await auth.signInAnonymously();
            t.is(user.anonymous, true);
            const now = new Date();
            const ref = database.ref().child(now.getTime().toString());
            const value = now.toString();
            t.wait('child_added', resolve => {
                ref.on('child_added', async (snapshot) => {
                    resolve((await snapshot.val()) === value);
                });
            });
            ref.push().setValue(value);
        });
    });
}
