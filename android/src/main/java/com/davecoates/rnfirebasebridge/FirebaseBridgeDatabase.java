package com.davecoates.rnfirebasebridge;

import android.support.annotation.Nullable;
import com.facebook.react.bridge.*;
import com.facebook.react.modules.core.RCTNativeAppEventEmitter;
import com.google.firebase.database.*;

import java.lang.reflect.Method;
import java.util.*;

class DatabaseReferenceListenerPair {
    public Query ref;
    public ValueEventListener valueListener;
    public ChildEventListener childListener;
    public DatabaseReferenceListenerPair(Query ref, ValueEventListener listener) {
        this.ref = ref;
        this.valueListener = listener;
    }
    public DatabaseReferenceListenerPair(Query ref, ChildEventListener listener) {
        this.ref = ref;
        this.childListener = listener;
    }

    public void unsubscribe() {
        if (this.valueListener != null) {
            this.ref.removeEventListener(this.valueListener);
        }
        if (this.childListener != null) {
            this.ref.removeEventListener(this.childListener);
        }
    }
}

public class FirebaseBridgeDatabase extends ReactContextBaseJavaModule {


    public FirebaseBridgeDatabase(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "FirebaseBridgeDatabase";
    }

    private WritableMap convertRef(DatabaseReference ref) {

        final WritableMap m = Arguments.createMap();
        m.putString("key", ref.getKey());
        m.putString("locationUrl", ref.toString());

        return m;
    }

    private DatabaseReference getRefFromUrl(String databaseUrl) {
        if (databaseUrl == null) {
            return FirebaseDatabase.getInstance().getReference();
        }
        return FirebaseDatabase.getInstance().getReferenceFromUrl(databaseUrl);
    }

    @ReactMethod
    public void child(String databaseUrl, String path, Promise promise) {
        promise.resolve(convertRef(getRefFromUrl(databaseUrl).child(path)));
    }

    @ReactMethod
    public void push(String databaseUrl, Promise promise) {
        promise.resolve(convertRef(getRefFromUrl(databaseUrl).push()));
    }

    /**
     * Value is always an array where the first element is the value to set.
     * This was the easiest way I could see to accept any value type without
     * having to implement individual setters (eg. setValueString).
     * @param databaseUrl
     * @param value
     */
    @ReactMethod
    public void setValue(String databaseUrl, ReadableArray value, final Promise promise) {
        DatabaseReference ref = getRefFromUrl(databaseUrl);
        Object v = null;
        switch(value.getType(0)) {
            case Null:
                v = null;
                break;
            case Boolean:
                v = value.getBoolean(0);
                break;
            case Number:
                v = value.getDouble(0);
                break;
            case String:
                v = value.getString(0);
                break;
            case Map:
                v = ((ReadableNativeMap)value.getMap(0)).toHashMap();
                break;
            case Array:
                v = ((ReadableNativeArray)value.getArray(0)).toArrayList();
                break;
        }
        ref.setValue(v, new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                if (databaseError != null) {
                    promise.reject(databaseError.toException());
                } else {
                    promise.resolve(null);
                }
            }
        });
    }

    /**
     * Value and priority are always an array where the first element is the
     * value / priority to set.
     * This was the easiest way I could see to accept any value type without
     * having to implement individual setters (eg. setValueString).
     * @param databaseUrl
     * @param value
     */
    @ReactMethod
    public void setValueWithPriority(String databaseUrl, ReadableArray value, ReadableArray priority, final Promise promise) {
        DatabaseReference ref = getRefFromUrl(databaseUrl);
        Object v = null;
        switch(value.getType(0)) {
            case Null:
                v = null;
                break;
            case Boolean:
                v = value.getBoolean(0);
                break;
            case Number:
                v = value.getDouble(0);
                break;
            case String:
                v = value.getString(0);
                break;
            case Map:
                v = ((ReadableNativeMap)value.getMap(0)).toHashMap();
                break;
            case Array:
                v = ((ReadableNativeArray)value.getArray(0)).toArrayList();
                break;
        }
        Object p = null;
        switch(priority.getType(0)) {
            case Number:
                p = priority.getDouble(0);
                break;
            case String:
                p = priority.getString(0);
                break;
        }
        ref.setValue(v, p, new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                if (databaseError != null) {
                    promise.reject(databaseError.toException());
                } else {
                    promise.resolve(null);
                }
            }
        });
    }

    @ReactMethod
    public void setPriority(String databaseUrl, ReadableArray value, final Promise promise) {
        DatabaseReference.CompletionListener listener = new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                if (databaseError != null) {
                    promise.reject(databaseError.toException());
                } else {
                    promise.resolve(null);
                }
            }
        };
        DatabaseReference ref = getRefFromUrl(databaseUrl);
        switch(value.getType(0)) {
            case Number:
                ref.setPriority(value.getDouble(0), listener);
                break;
            case String:
                ref.setPriority(value.getString(0), listener);
                break;
            default:
                ref.setPriority(null, listener);
                break;
        }
    }

    /**
     * Remove a value from provided location. Promise resolves once completed on server, or rejects
     * if there was a database error.
     * @param databaseUrl
     * @param promise
     */
    @ReactMethod
    public void removeValue(String databaseUrl, final Promise promise) {
        DatabaseReference ref = getRefFromUrl(databaseUrl);
        ref.removeValue(new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                if (databaseError != null) {
                    promise.reject(databaseError.toException());
                } else {
                    promise.resolve(null);
                }
            }
        });
    }

    private void sendEvent(String eventName,
                         @Nullable WritableMap params) {
        ReactContext reactContext = getReactApplicationContext();
        reactContext
                .getJSModule(RCTNativeAppEventEmitter.class)
                .emit(eventName, params);
    }

    private WritableArray convertSnapshotList(Iterable<DataSnapshot> values) {
        WritableArray data = Arguments.createArray();
        for (DataSnapshot child : values) {
            Object value = child.getValue();
            switch (value.getClass().getName()) {
                case "java.lang.Boolean":
                    data.pushBoolean((Boolean)value);
                    break;
                case "java.lang.Long":
                    Long v = (Long)value;
                    data.pushDouble(v.doubleValue());
                    break;
                case "java.lang.Integer":
                    data.pushInt((Integer)value);
                    break;
                case "java.lang.Double":
                    data.pushDouble((Double)value);
                    break;
                case "java.lang.String":
                    data.pushString((String)value);
                    break;
                case "java.util.HashMap":
                    WritableMap childMap = convertSnapshotMap(child.getChildren());
                    data.pushMap(childMap);
                    break;
                case "java.util.ArrayList":
                    WritableArray childList = convertSnapshotList(child.getChildren());
                    data.pushArray(childList);
                    break;
                default:
                    data.pushNull();
                    break;
            }
        }
        return data;
    }

    private WritableMap convertSnapshotMap(Iterable<DataSnapshot> values) {
        WritableMap data = Arguments.createMap();
        for (DataSnapshot child : values) {
            Object value = child.getValue();
            switch (value.getClass().getName()) {
                case "java.lang.Boolean":
                    data.putBoolean(child.getKey(), (Boolean)value);
                    break;
                case "java.lang.Long":
                    Long v = (Long)value;
                    data.putDouble(child.getKey(), v.doubleValue());
                    break;
                case "java.lang.Integer":
                    data.putInt(child.getKey(), (Integer)value);
                    break;
                case "java.lang.Double":
                    data.putDouble(child.getKey(), (Double)value);
                    break;
                case "java.lang.String":
                    data.putString(child.getKey(), (String)value);
                    break;
                case "java.util.HashMap":
                    WritableMap childMap = convertSnapshotMap(child.getChildren());
                    data.putMap(child.getKey(), childMap);
                    break;
                case "java.util.ArrayList":
                    data.putArray(child.getKey(), convertSnapshotList(child.getChildren()));
                    break;
                default:
                    data.putNull(child.getKey());
                    break;
            }
        }
        return data;
    }

    @ReactMethod
    public void snapshotValue(String snapshotUUID, Promise promise) {
        DataSnapshot snapshot = snapshotCache.get(snapshotUUID);
        if (null == snapshot) {
            promise.reject("snapshot_not_found", "Snapshot not found; it may have been released.");
            return;
        }

        Object value = snapshot.getValue();
        if (value == null) {
            promise.resolve(null);
            return;
        }
        switch (value.getClass().getName()) {
            case "java.lang.Boolean":
                promise.resolve((Boolean)value);
                break;
            case "java.lang.Integer":
                promise.resolve((Integer)value);
                break;
            case "java.lang.Double":
                promise.resolve((Double)value);
                break;
            case "java.lang.String":
                promise.resolve((String)value);
                break;
            case "java.util.HashMap":
                promise.resolve(convertSnapshotMap(snapshot.getChildren()));
                break;
            case "java.util.ArrayList":
                promise.resolve(convertSnapshotList(snapshot.getChildren()));
                break;
            default:
                promise.resolve(null);
        }
    }

    @ReactMethod
    public void snapshotExportValue(String snapshotUUID, Promise promise) {
        DataSnapshot snapshot = snapshotCache.get(snapshotUUID);
        if (null == snapshot) {
            promise.reject("snapshot_not_found", "Snapshot not found");
            return;
        }

        Object value = snapshot.getValue(true);
        switch (value.getClass().getName()) {
            case "java.lang.Boolean":
                promise.resolve((Boolean)value);
                break;
            case "java.lang.Integer":
                promise.resolve((Integer)value);
                break;
            case "java.lang.Double":
                promise.resolve((Double)value);
                break;
            case "java.lang.String":
                promise.resolve((String)value);
                break;
            case "java.util.HashMap":
                promise.resolve(convertSnapshotMap(snapshot.getChildren()));
                break;
            case "java.util.ArrayList":
                promise.resolve(convertSnapshotList(snapshot.getChildren()));
                break;
            default:
                promise.resolve(null);
        }
    }

    @ReactMethod
    public void snapshotChild(String snapshotUUID, String path, Promise promise)
    {
        DataSnapshot snapshot = snapshotCache.get(snapshotUUID);
        if (null == snapshot) {
            promise.reject("snapshot_not_found", "Snapshot not found");
            return;
        }
        DataSnapshot childSnapshot = snapshot.child(path);
        promise.resolve(convertSnapshot(childSnapshot));
    }

    @ReactMethod
    public void snapshotChildren(String snapshotUUID, Promise promise)
    {
        DataSnapshot snapshot = snapshotCache.get(snapshotUUID);
        if (null == snapshot) {
            promise.reject("snapshot_not_found", "Snapshot not found");
            return;
        }
        WritableArray snapshots = Arguments.createArray();
        for (DataSnapshot child : snapshot.getChildren()) {
            snapshots.pushMap(convertSnapshot(child));
        }
        promise.resolve(snapshots);
    }

    @ReactMethod
    public void snapshotHasChild(String snapshotUUID, String path, Promise promise)
    {
        DataSnapshot snapshot = snapshotCache.get(snapshotUUID);
        if (null == snapshot) {
            promise.reject("snapshot_not_found", "Snapshot not found");
            return;
        }
        promise.resolve(snapshot.hasChild(path));
    }

    @ReactMethod
    public void releaseSnapshot(String snapshotUUID)
    {
        if (snapshotCache.containsKey(snapshotUUID)) {
            snapshotCache.remove(snapshotUUID);
        }
    }

    private Map<String, DataSnapshot> snapshotCache = new HashMap<>();

    private WritableMap convertSnapshot(DataSnapshot snapshot) {
        UUID id = UUID.randomUUID();
        snapshotCache.put(id.toString(), snapshot);

        WritableMap data = Arguments.createMap();
        data.putMap("ref", convertRef(snapshot.getRef()));
        data.putDouble("childrenCount", (double)snapshot.getChildrenCount());
        data.putBoolean("hasChildren", snapshot.hasChildren());
        data.putBoolean("exists", snapshot.exists());
        data.putString("uuid", id.toString());
        Object priority = snapshot.getPriority();
        if (priority instanceof String) {
            data.putString("priority", (String)priority);
        } else if (priority instanceof Double) {
            data.putDouble("priority", (Double)priority);
        } else {
            data.putNull("priority");
        }

        return data;
    }

    private Map<String, DatabaseReferenceListenerPair> listenersByUUID = new HashMap<>();

    @ReactMethod
    public void on(String databaseUrl, final String eventType, ReadableArray query, Promise promise) {
        // This is the event name that will be fired on the JS side whenever
        // the Firebase event occurs. An event listener is registered here
        // which then fires the event on the JS bridge.
        final UUID uniqueEventName = UUID.randomUUID();
        Query ref = getRefFromUrl(databaseUrl);
        for (int i = 0; i< query.size(); i++) {
            ReadableArray queryDescriptor = query.getArray(i);
            String fnName = queryDescriptor.getString(0);
            int paramCount = queryDescriptor.size() - 1;
            switch(fnName) {
                case "orderByChild":
                    ref = ref.orderByChild(queryDescriptor.getString(1));
                    break;
                case "orderByKey":
                    ref = ref.orderByKey();
                    break;
                case "orderByPriority":
                    ref = ref.orderByPriority();
                    break;
                case "orderByValue":
                    ref = ref.orderByValue();
                    break;
                case "startAt":
                case "endAt":
                case "equalTo":
                    if (paramCount < 1 || paramCount > 2) {
                        promise.reject(
                                "invalid_query",
                                fnName + " takes either 1 or two parameters"
                        );
                        return;
                    }
                    if (paramCount == 2 && queryDescriptor.getType(2) != ReadableType.String) {
                        promise.reject(
                                "invalid_query",
                                fnName + " second parameter must be a string"
                        );
                        return;
                    }
                    Class<?>[] paramTypes = new Class[paramCount];
                    if (paramCount == 2) {
                        paramTypes[1] = String.class;
                    }
                    Method method;
                    try {
                        switch (queryDescriptor.getType(1)) {
                            case Boolean:
                                boolean b = queryDescriptor.getBoolean(1);
                                paramTypes[0] = boolean.class;
                                method = ref.getClass().getMethod(fnName, paramTypes);
                                if (paramCount == 2) {
                                    ref = (Query) method.invoke(ref, b, queryDescriptor.getString(2));
                                } else {
                                    ref = (Query) method.invoke(ref, b);
                                }
                                break;
                            case Number:
                                double d = queryDescriptor.getDouble(1);
                                paramTypes[0] = double.class;
                                method = ref.getClass().getMethod(fnName, paramTypes);
                                if (paramCount == 2) {
                                    ref = (Query) method.invoke(ref, d, queryDescriptor.getString(2));
                                } else {
                                    ref = (Query) method.invoke(ref, d);
                                }
                                break;
                            case String:
                                String s = queryDescriptor.getString(1);
                                paramTypes[0] = String.class;
                                method = ref.getClass().getMethod(fnName, paramTypes);
                                if (paramCount == 2) {
                                    ref = (Query) method.invoke(ref, s, queryDescriptor.getString(2));
                                } else {
                                    ref = (Query) method.invoke(ref, s);
                                }
                                break;
                            default:
                                promise.reject(
                                        "invalid_query",
                                        "Unexpected type passed as first parameter to " + fnName + ". Should be Boolean, Number or String."
                                );
                                break;
                        }
                    } catch (Exception e) {
                        promise.reject(e);
                    }
                    break;
                case "limitToFirst":
                    ref = ref.limitToFirst(queryDescriptor.getInt(1));
                    break;
                case "limitToLast":
                    ref = ref.limitToLast(queryDescriptor.getInt(1));
                    break;
                default:
                    promise.reject("invalid_query", "Unknown query function " + fnName);
                    return;
            }
        }
        switch (eventType) {
            case "value":
                ValueEventListener listener = new ValueEventListener() {
                    @Override
                    public void onDataChange(DataSnapshot dataSnapshot) {
                        sendEvent(uniqueEventName.toString(), convertSnapshot(dataSnapshot));
                    }

                    @Override
                    public void onCancelled(DatabaseError databaseError) {
                    }
                };
                listenersByUUID.put(uniqueEventName.toString(), new DatabaseReferenceListenerPair(ref, listener));
                ref.addValueEventListener(listener);
                promise.resolve(uniqueEventName.toString());
                break;
            case "child_added":
            case "child_removed":
            case "child_changed":
            case "child_moved":
                ChildEventListener childListener = new ChildEventListener() {
                    @Override
                    public void onChildAdded(DataSnapshot dataSnapshot, String s) {
                        if (eventType.equals("child_added")) {
                            sendEvent(uniqueEventName.toString(), convertSnapshot(dataSnapshot));
                        }
                    }

                    @Override
                    public void onChildChanged(DataSnapshot dataSnapshot, String s) {
                        if (eventType.equals("child_changed")) {
                            sendEvent(uniqueEventName.toString(), convertSnapshot(dataSnapshot));
                        }
                    }

                    @Override
                    public void onChildRemoved(DataSnapshot dataSnapshot) {
                        if (eventType.equals("child_removed")) {
                            sendEvent(uniqueEventName.toString(), convertSnapshot(dataSnapshot));
                        }
                    }

                    @Override
                    public void onChildMoved(DataSnapshot dataSnapshot, String s) {
                        if (eventType.equals("child_moved")) {
                            sendEvent(uniqueEventName.toString(), convertSnapshot(dataSnapshot));
                        }
                    }

                    @Override
                    public void onCancelled(DatabaseError databaseError) {

                    }
                };
                listenersByUUID.put(uniqueEventName.toString(), new DatabaseReferenceListenerPair(ref, childListener));
                ref.addChildEventListener(childListener);
                promise.resolve(uniqueEventName.toString());
                break;
            default:
                promise.reject("unknown_event", "Unknown event type " + eventType);
        }
    }

    @ReactMethod
    public void off(String uniqueEventName) {
        // uniqueEventName here matches one create in on()
        if (listenersByUUID.containsKey(uniqueEventName)) {
            listenersByUUID.get(uniqueEventName).unsubscribe();
            listenersByUUID.remove(uniqueEventName);
        }
    }

    static private boolean persistenceEnabled = false;

    @ReactMethod
    public void setPersistenceEnabled(boolean enabled) {
        if (FirebaseBridgeDatabase.persistenceEnabled != enabled) {
            FirebaseBridgeDatabase.persistenceEnabled = enabled;
            FirebaseDatabase.getInstance().setPersistenceEnabled(enabled);
        }
    }

}
