import React, { Component } from 'react';
import { View, StyleSheet, Text } from 'react-native';

const styles = StyleSheet.create({
    suite: {
        flexDirection: 'row',
        flexWrap: 'wrap',
    },
    result: {
        borderRightWidth: 1,
        borderStyle: 'solid',
        borderColor: 'black',
    },
    success: {
        color: 'green',
    },
    error: {
        color: 'red',
    },
});

export default class TestSuite extends Component {

    componentWillMount() {
        this.runSuite(this.props.suite);
    }

    componentWillReceiveProps(nextProps) {
        this.runSuite(nextProps.suite);
    }

    async runSuite(run) {
        this.setState({ pending: true });
        const results = await run();
        results.forEach(({ label, errors, passed }) => {
            if (errors.length) {
                console.group(`${label} (${passed} passed, ${errors.length} failed)`);
                errors.map(error => console.log(error));
                console.groupEnd();
            }
        });
        this.setState({ pending: false, results });
    }

    render() {
        const { results, pending } = this.state;
        if (pending) {
            return <Text>.</Text>;
        }
        return (
            <View style={styles.suite}>
                {results.map(({ errors, passed }, i) =>
                    <Text key={i} style={[
                        errors.length ? styles.error : styles.success,
                        styles.result
                    ]}>
                        <Text style={styles.success}>✓ {passed}</Text>
                        ✘ {errors.length}
                    </Text>
                )}
            </View>
        );
    }

}
