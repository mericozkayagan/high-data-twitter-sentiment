package com.twitter.streams;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.kafka.common.serialization.Deserializer;
import org.apache.kafka.common.serialization.Serde;
import org.apache.kafka.common.serialization.Serializer;

import java.nio.charset.StandardCharsets;

/**
 * Custom Serde (Serializer/Deserializer) for Tweet objects in Kafka Streams.
 */
public class TweetSerde implements Serde<Tweet> {
    
    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public Serializer<Tweet> serializer() {
        return new TweetSerializer();
    }

    @Override
    public Deserializer<Tweet> deserializer() {
        return new TweetDeserializer();
    }

    /**
     * Serializes Tweet objects to JSON bytes.
     */
    public static class TweetSerializer implements Serializer<Tweet> {
        
        @Override
        public byte[] serialize(String topic, Tweet data) {
            if (data == null) {
                return null;
            }
            try {
                return objectMapper.writeValueAsBytes(data);
            } catch (Exception e) {
                throw new RuntimeException("Error serializing Tweet", e);
            }
        }
    }

    /**
     * Deserializes JSON bytes to Tweet objects.
     */
    public static class TweetDeserializer implements Deserializer<Tweet> {
        
        @Override
        public Tweet deserialize(String topic, byte[] data) {
            if (data == null) {
                return null;
            }
            try {
                return objectMapper.readValue(data, Tweet.class);
            } catch (Exception e) {
                // Log error and return null for malformed messages
                System.err.println("Error deserializing Tweet: " + new String(data, StandardCharsets.UTF_8));
                return null;
            }
        }
    }
}

