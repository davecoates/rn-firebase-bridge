import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  View
} from 'react-native';
import { Container, Content, List, ListItem, Text, Icon } from 'native-base';
import firebase from '../../firebase';
import DatabaseTest from './DatabaseTest';

//import Database from '../../database.js';

class Expect extends Component {

    state = {};

    componentWillMount() {
        this.run(this.props);
    }

    componentWillReceiveProps(nextProps) {
        this.run(nextProps);
    }

    async run(props) {
        let success;
        let error;
        try {
            const value = await props.value;
            if (props.toEqual) {
                success = value === props.toEqual;
                if (!success) {
                    error = `Expected '${value}' to equal '${props.toEqual}'`;
                }
            }
            if (props.toBeTruthy) {
                success = !!value;
                if (!success) {
                    error = `Expected '${value}' to be truthy`;
                }
            }
        } catch (e) {
            success = props.toThrow;
        }
        this.setState({ finished: true, success, error });
    }

    render() {
        const { success, finished, error } = this.state;
        const { desc } = this.props;
        if (!finished) {
            return <ListItem><Text>{desc} - Pending</Text></ListItem>;
        }
        return (
            <ListItem iconRight>
                <Text style={{color: error ? 'red' : 'black'}}>
                    {desc} {error && `: ${error}`}
                </Text>
                <Icon name={error ? 'ios-close-circle' : 'ios-checkmark'} style={{color: error ? 'red' : 'green'}}/>
            </ListItem>
        );
    }

}

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
        console.log(this.defaultApp, this.otherApp)
        return (
            <Container>
                <Content>
                    <DatabaseTest app={this.defaultApp} />
                    <DatabaseTest app={this.otherApp} />
                </Content>>
            </Container>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    welcome: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    instructions: {
        textAlign: 'center',
        color: '#333333',
        marginBottom: 5,
    },
});

AppRegistry.registerComponent('testapp', () => testapp);
