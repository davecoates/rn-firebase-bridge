import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
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
        this.otherApp = await firebase.initializeApp({
            APIKey: 'AIzaSyCl_ImAtqkkigLNrsK1XSOjPhzIQqFov4M',
            googleAppID: '1:698755699724:ios:21914d25bfa88493',
            databaseURL: 'https://fir-bridge2.firebaseio.com',
            clientID: '698755699724-cf6i04ghv6m16d10qlerlsepldj9pvqj.apps.googleusercontent.com',
            bundleID: 'com.testapp',
            GCMSenderID: '698755699724',
            storageBucket: 'fir-bridge2.appspot.com',
        }, 'AnotherApp');
        this.setState({ ready: true });
    }
    render() {
        if (!this.state.ready) {
            return <View><Text>Initializing...</Text></View>;
        }
        return (
            <View style={styles.container}>
                    <DatabaseTest app={this.defaultApp} />
                    <DatabaseTest app={this.otherApp} />
                    {/*<AuthTest app={this.defaultApp} />*/}
                    <AuthTest app={this.otherApp} />
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        marginTop: 20,
    },
});

AppRegistry.registerComponent('testapp', () => testapp);
