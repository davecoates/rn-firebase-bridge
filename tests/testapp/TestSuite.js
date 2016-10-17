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
    noError: {
        color: 'gray',
        opacity: 0.5,
    },
    button: {
        borderWidth: 1,
        borderRadius: 5,
        width: 300,
        margin: 5,
        padding: 5,
    },
});

export default class TestSuite extends Component {

    state = {
        started: false,
    };

    componentWillReceiveProps(nextProps) {
        if (this.state.started) {
            this.runSuite(nextProps.suite);
        }
    }

    runSuite = async (run) => {
        this.setState({ pending: true, started: true });
        const results = await run();
        results.forEach(({ label, errors, passed }) => {
            if (errors.length) {
                console.group( // eslint-disable-line
                    `${label} (${passed} passed, ${errors.length} failed)`);
                errors.map(error => console.log(error)); // eslint-disable-line
                console.groupEnd(); // eslint-disable-line
            }
        });
        this.setState({ pending: false, results });
    };

    render() {
        const { results, pending, started } = this.state;
        if (!started) {
            return (
                <Text
                    style={styles.button}
                    onPress={this.runSuite.bind(this, this.props.suite)}
                >
                    Run
                </Text>
            );
        }
        if (pending) {
            return <Text>.</Text>;
        }
        return (
            <View style={styles.suite}>
                {results.map(({ errors, passed }, i) =>
                    <Text key={i} style={styles.result}>
                        <Text style={styles.success}>✓ {passed}</Text>
                        <Text style={errors.length ? styles.error : styles.noError}>
                            ✘ {errors.length}
                        </Text>
                    </Text>
                )}
            </View>
        );
    }

}
