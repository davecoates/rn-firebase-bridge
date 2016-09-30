import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  ScrollView,
  View,
  Text,
} from 'react-native';
import firebase from '../../firebase';
import DatabaseTest from './DatabaseTest';
import AuthTest from './AuthTest';

class testapp extends Component {
    state = { ready: false };
    async componentWillMount() {
        this.defaultApp = await firebase.initializeDefaultApp();
        this.otherApp = await firebase.initializeApp(require('./app2-credentials.json'), 'AnotherApp');
        this.setState({ ready: true });
    }
    render() {
        if (!this.state.ready) {
            return <View><Text>Initializing...</Text></View>;
        }
        return (
            <ScrollView style={styles.container}>
                <DatabaseTest app={this.defaultApp} />
                <DatabaseTest app={this.otherApp} />
                <AuthTest app={this.defaultApp} />

                {/*
                    <AuthTest app={this.otherApp} />
                */}
            </ScrollView>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        marginTop: 20,
    },
});

AppRegistry.registerComponent('testapp', () => testapp);
