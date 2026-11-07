package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class HealthController {

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "UP");
    }

    @GetMapping("/ready")
    public Map<String, String> ready() {
        return Map.of("status", "READY");
    }

    @GetMapping("/version")
    public Map<String, String> version() {
        return Map.of(
                "app", "sample-service",
                "version", "1.0.0"
        );
    }
}