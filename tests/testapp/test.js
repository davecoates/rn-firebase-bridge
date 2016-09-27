async function test(label, fn) {
    const errors = [];
    let passed = 0;
    const promises = [];
    const t = {
        async is(value, expected) {
            const p = new Promise(async resolve => {
                const a = await value;
                const b = await expected;
                if (a !== b) {
                    errors.push(`${a} != ${b}`);
                } else {
                    passed++;
                }
                resolve();
            });
            promises.push(p);
        },
        async wait(desc, f, timeout = 2000) {
            promises.push(new Promise((resolve, reject) => {
                f(resolve, reject);
                setTimeout(() => reject(new Error(desc + ': Timeout')), timeout);
            }));
        },
    };
    try {
        await Promise.race([
            fn(t),
            new Promise((_, reject) => setTimeout(
                () => reject(new Error('Timeout reached')),
                15000
            )),
        ]);
        await Promise.race([
            Promise.all(promises),
            new Promise((_, reject) => setTimeout(
                () => reject(new Error('Timeout reached')),
                15000
            )),
        ]);
    } catch (e) {
        errors.push('Uncaught exception: ' + e.message);
    }
    return { label, passed, errors };
}

export default function suite(makeTests) {
    const tests = [];
    makeTests((...params) => tests.push(test.bind(null, ...params)));

    return async function runSuite() {
        const results = [];
        for (const test of tests) {
            results.push(await test());
        }
        return results;
    }
}
