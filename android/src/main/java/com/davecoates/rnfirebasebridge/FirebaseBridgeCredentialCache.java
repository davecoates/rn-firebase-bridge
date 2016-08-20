package com.davecoates.rnfirebasebridge;

import com.google.firebase.auth.AuthCredential;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class FirebaseBridgeCredentialCache {

    static private Map<String, AuthCredential> credentialCache = new HashMap<>();

    static String addCredential(AuthCredential credential) {
        UUID credentialUUID = UUID.randomUUID();
        credentialCache.put(credentialUUID.toString(), credential);
        return credentialUUID.toString();
    }

    static AuthCredential getCredential(String id) {
        return credentialCache.get(id);
    }

}
