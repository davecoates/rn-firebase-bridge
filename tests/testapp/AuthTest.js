import React, { Component } from 'react';
import { Text, View, StyleSheet } from 'react-native';
import TestSuite from './TestSuite';
import makeSuite from './auth.spec.js';

export default class AuthTest extends Component {

    render() {
        return (
            <View>
                <Text>Auth Tests - {this.props.app.name}</Text>
                <TestSuite suite={makeSuite(this.props.app)} />
            </View>
        );
    }
}
