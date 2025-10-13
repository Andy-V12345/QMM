package com.qmm.userservices;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import io.github.cdimascio.dotenv.Dotenv;

@SpringBootApplication
public class UserservicesApplication {

	public static void main(String[] args) {
		Dotenv dotenv = Dotenv.configure().load();

		dotenv.entries().forEach(entry -> {
            System.setProperty(entry.getKey(), entry.getValue());
        });

		System.out.println(System.getProperty("GOOGLE_APPLICATION_CREDENTIALS"));
		
		SpringApplication.run(UserservicesApplication.class, args);
	}

}
