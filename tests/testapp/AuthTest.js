import React, { Component } from 'react';
import prettyFormat from 'pretty-format';
import { Text, ScrollView, View, StyleSheet, TextInput } from 'react-native';
import TestSuite from './TestSuite';
import makeSuite from './auth.spec.js';
import firebase from '../../firebase';

const defaultState = require('./testingState.json');

const styles = StyleSheet.create({
    container: {
        borderTopWidth: 2,
        borderBottomWidth: 2,
    },
    user: {
        paddingTop: 20,
    },
    button: {
        borderWidth: 1,
        borderRadius: 5,
        width: 300,
        margin: 5,
        padding: 5,
    },
    heading: {
        fontWeight: 'bold',
        margin: 10,
    },
    default: {
        height: 26,
        borderWidth: 0.5,
        borderColor: '#0f0f0f',
        flex: 1,
        fontSize: 13,
        padding: 4,
    },
});

/**
 * To test github:
 * Go to https://github.com/login/oauth/authorize?client_id=<client id>
 * Get code and post to
 * https://github.com/login/oauth/access_token with code, client id and secret
 * Take token and use below
 */

 class ActionWithResult extends Component {

    state = {
        result: null,
        error: null,
        hasRun: false,
    };

    onPress = async () => {
        const { action } = this.props;
        this.setState({ result: null, error: null, hasRun: false });
        try {
            const result = await action();
            this.setState({ result, hasRun: true });
        } catch (error) {
            this.setState({ error, hasRun: true });
        }
    }

    render() {
        const { buttonText } = this.props;
        const { result, error, hasRun } = this.state;

        return (
            <View>
                <Text
                    style={styles.button}
                    onPress={this.onPress}
                >
                    {buttonText}
                </Text>
                {hasRun && (
                    <Text>
                        {error ? 'Error: ' : 'Success: '}
                        {prettyFormat(error || result)}
                    </Text>
                )}
            </View>
        );
    }

 }

export default class AuthTest extends Component {

    state = {
        email: defaultState.email,
        password: defaultState.password,
    };

    componentWillUnmount() {
        this.unsub();
    }

    componentDidMount() {
        this.unsub = this.props.app.auth().onAuthStateChanged((user) => {
            this.setState({ user });
        });
    }

    signIn = async () => {
        this.setState({ error: null });
        try {
            const { email, password } = this.state;
            await this.props.app.auth().signInWithEmail(email, password);
        } catch (error) {
            this.setState({ error });
        }
    };

    createUser = async () => {
        this.setState({ error: null, createUserResult: null });
        try {
            const { email, password } = this.state;
            const createUserResult = await this.props.app.auth()
                .createUserWithEmailAndPassword(email, password);
            this.setState({ createUserResult });
        } catch (error) {
            this.setState({ error });
        }
    };

    emailChange = e => {
        this.setState({ email: e.nativeEvent.text });
    };

    passwordChange = e => {
        this.setState({ password: e.nativeEvent.text });
    };

    signOut = () => this.props.app.auth().signOut();

    sendPasswordResetEmail = async () => {
        try {
            await this.props.app.auth().sendPasswordResetEmail(this.state.email);
        } catch (error) {
            this.setState({ error });
        }
    }

    fetchProvidersForEmail = async () => {
        try {
            const providers = await this.props.app.auth().fetchProvidersForEmail(this.state.email);
            this.setState({ providers });
        } catch (error) {
            this.setState({ error });
        }
    }

    toggleExpanded = () => this.setState({ expanded: !this.state.expanded });

    githubToken = e => {
        this.setState({ githubToken: e.nativeEvent.text });
    };

    loginWithGithub = async () => {
        const token = this.state.githubToken;
        const credential = firebase.auth.GithubAuthProvider.credential(token);
        try {
            await this.props.app.auth().signInWithCredential(credential);
        } catch (error) {
            this.setState({ error });
        }
    };

    linkWithGithub = async () => {
        const token = this.state.githubToken;
        const credential = firebase.auth.GithubAuthProvider.credential(token);
        return this.props.app.auth().currentUser.link(credential);
    };

    render() {
        const {
            providers, githubToken, expanded, email, password, user, error, createUserResult,
        } = this.state;
        const auth = this.props.app.auth();
        return (
            <View style={styles.container}>
                <Text>Auth Tests - {this.props.app.name}</Text>
                <Text style={styles.button} onPress={this.toggleExpanded}>
                    {expanded ? 'Collapse' : 'Expand'}
                </Text>
                {/* Easy to get device blocked by running these,
                just stick to manual testing <TestSuite suite={makeSuite(this.props.app)} /> */}
                {expanded &&
                    <ScrollView>
                        <Text style={styles.user}>User: {prettyFormat(user)}</Text>
                        <Text style={styles.user}>Error: {prettyFormat(error)}</Text>
                        <Text style={styles.user}>
                            Create User Result: {prettyFormat(createUserResult)}
                        </Text>
                        <Text style={styles.button} onPress={this.signOut}>
                            Sign Out
                        </Text>
                        <Text style={styles.heading}>Sign in with email:</Text>
                        <TextInput
                            style={styles.default}
                            value={email}
                            onChange={this.emailChange}
                            placeholder="Email"
                        />
                        <TextInput
                            style={styles.default}
                            value={password}
                            onChange={this.passwordChange}
                            placeholder="Password"
                        />
                        <Text onPress={this.signIn} style={styles.button}>Sign In</Text>

                        <Text style={styles.heading}>Create user:</Text>
                        <TextInput
                            style={styles.default}
                            value={email}
                            onChange={this.emailChange}
                            placeholder="Email"
                        />
                        <TextInput
                            style={styles.default}
                            value={password}
                            onChange={this.passwordChange}
                            placeholder="Password"
                        />
                        <Text onPress={this.createUser} style={styles.button}>Create</Text>

                        <Text style={styles.heading}>Github auth:</Text>
                        <TextInput
                            capitalize="none"
                            style={styles.default}
                            value={githubToken}
                            onChange={this.githubToken}
                            placeholder="github token"
                        />
                        <Text onPress={this.loginWithGithub} style={styles.button}>
                            Login with github
                        </Text>

                        <TextInput
                            style={styles.default}
                            value={email}
                            onChange={this.emailChange}
                            placeholder="Email"
                        />
                        <Text
                            onPress={this.sendPasswordResetEmail}
                            style={styles.button}
                        >Send password reset</Text>
                        <TextInput
                            style={styles.default}
                            value={email}
                            onChange={this.emailChange}
                            placeholder="Email"
                        />
                        <Text
                            onPress={this.fetchProvidersForEmail}
                            style={styles.button}
                        >Fetch providers for email</Text>
                        <Text>Providers: {providers ? providers.join(', ') : 'None'}</Text>

                        <Text style={styles.heading}>
                            User functions
                        </Text>
                        <ActionWithResult
                            action={() => auth.currentUser.sendEmailVerification()}
                            buttonText="Send Email Verification"
                        />
                        <ActionWithResult
                            action={() => auth.currentUser.delete()}
                            buttonText="Delete"
                        />
                        <ActionWithResult
                            action={() => auth.currentUser.getToken()}
                            buttonText="getToken"
                        />
                        <ActionWithResult
                            action={() => auth.currentUser.reload()}
                            buttonText="Reload"
                        />
                        <ActionWithResult
                            action={() => auth.currentUser.updatePassword('password2')}
                            buttonText="Update password (password2)"
                        />
                        <ActionWithResult
                            action={() => auth.currentUser.updatePassword('password')}
                            buttonText="Update password (password)"
                        />
                        <ActionWithResult
                            action={this.linkWithGithub}
                            buttonText="Link with github (fill token above)"
                        />
                        <ActionWithResult
                            action={() => auth.currentUser.unlink('github.com')}
                            buttonText="Unlink github"
                        />
                        <ActionWithResult
                            action={() => auth.currentUser.updateProfile({
                                displayName: Math.random().toString(),
                            })}
                            buttonText="Update display name"
                        />
                    </ScrollView>
                }
            </View>
        );
    }
}
