import React, { Component } from 'react';
import { ListItem, Text, Icon } from 'native-base';


export default class Expect extends Component {

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
            const value = await (typeof props.value == 'function' ? props.value() : props.value);
            if (props.toEqual) {
                success = value === props.toEqual;
                if (!success) {
                    error = `Expected '${value.toString()}' to equal '${props.toEqual}'`;
                    if (value != null && typeof value == 'object') {
                        console.info(error, value); // eslint-disable-line
                    }
                }
            }
            if (props.toBeTruthy) {
                success = !!value;
                if (!success) {
                    error = `Expected '${value.toString()}' to be truthy`;
                    if (value != null && typeof value == 'object') {
                        console.info(error, value); // eslint-disable-line
                    }
                }
            }
        } catch (e) {
            success = props.toThrow;
            if (!success) {
                error = e.message;
                console.error(e); // eslint-disable-line
            }
        }
        this.setState({ finished: true, success, error });
    }

    render() {
        const { finished, error } = this.state;
        const { desc } = this.props;
        if (!finished) {
            return <ListItem><Text>{desc} - Pending</Text></ListItem>;
        }
        return (
            <ListItem iconRight>
                <Text style={{ color: error ? 'red' : 'black' }}>
                    {desc} {error && `: ${error}`}
                </Text>
                <Icon
                    name={error ? 'ios-close-circle' : 'ios-checkmark'}
                    style={{ color: error ? 'red' : 'green' }}
                />
            </ListItem>
        );
    }

}
