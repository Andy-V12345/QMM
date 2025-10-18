package com.qmm.userservices.configuration;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

import java.io.FileInputStream;
import java.io.IOException;

@Configuration
public class FirebaseConfiguration {

    @Autowired
    Environment env;

    @Bean
    public Firestore firestore() throws IOException {
        String credentialsPath = env.getProperty("GOOGLE_APPLICATION_CREDENTIALS");
        if (credentialsPath == null) {
            throw new IllegalStateException("GOOGLE_APPLICATION_CREDENTIALS not set");
        }

        FileInputStream serviceAccount = new FileInputStream(credentialsPath);
        GoogleCredentials credentials = GoogleCredentials.fromStream(serviceAccount);
        FirebaseOptions options = new FirebaseOptions.Builder().setCredentials(credentials).build();
        FirebaseApp.initializeApp(options);

        return FirestoreClient.getFirestore();
    }
}
