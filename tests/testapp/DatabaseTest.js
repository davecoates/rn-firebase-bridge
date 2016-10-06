import React, { Component } from 'react';
import { Text, View, StyleSheet } from 'react-native';
import TestSuite from './TestSuite';
import makeSuite from './database.spec.js';
import Database from '../../database';

export default class DatabaseTest extends Component {

    render() {
        return (
            <View>
                <Text>Database Tests - {this.props.app.name}</Text>
                <TestSuite suite={makeSuite(this.props.app)} />
            </View>
        );
    }
}
