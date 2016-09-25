import React, { Component } from 'react';
import { List, ListItem, Text, Icon } from 'native-base';
import Expect from './Expect';

export default class DatabaseTest extends Component {

    render() {
        const { app } = this.props;
        const dbUrl = app.options.databaseURL;
        const database = app.database();
        const base = String(Math.random()).split('.')[1];
        return (
            <List>
                <ListItem itemDivider>
                    <Text>{app.name}</Text>
                </ListItem>
                <Expect
                    value={database.ref(base).key()}
                    toEqual={base}
                    desc="ref with path key"
                />
                <Expect
                    value={database.ref(base).toString()}
                    toEqual={`${dbUrl}/${base}`}
                    desc="ref with path toString "
                />
                <Expect
                    value={database.ref().key()}
                    toEqual=""
                    desc="ref no path key"
                />
                <Expect
                    value={database.ref().toString()}
                    toEqual={dbUrl}
                    desc="ref no path toString"
                />
                <Expect
                    value={database.ref(base).root().toString()}
                    toEqual={dbUrl}
                    desc="ref key"
                />
                <Expect
                    value={database.ref().child('test').toString()}
                    toEqual={`${dbUrl}/test`}
                    desc="child ref"
                />
                <Expect
                    value={() => database.ref().child('test').push().setValue(1)}
                    toThrow
                    desc="ref key"
                />
            </List>
);
}
}
