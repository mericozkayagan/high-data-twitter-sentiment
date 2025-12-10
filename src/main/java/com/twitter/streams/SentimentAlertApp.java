package com.twitter.streams;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.Consumed;
import org.apache.kafka.streams.kstream.KStream;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Properties;
import java.util.concurrent.CountDownLatch;

/**
 * Real-Time Airline Complaint Alerting Application
 * 
 * Use Case A: Process the tweet stream message by message.
 * If a tweet's airline_sentiment is "negative", print an alert
 * to the console with the airline and the tweet text.
 * 
 * Track 2A: Apache Kafka Streams
 */
public class SentimentAlertApp {

    private static final String INPUT_TOPIC = "tweets_topic";
    private static final String OUTPUT_TOPIC = "realtime_alerts";
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final String LINE = "================================================================================";

    public static void main(String[] args) {
        // Kafka Streams configuration
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "sentiment-alert-app");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, getBootstrapServers());
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
        
        // Processing guarantee
        props.put(StreamsConfig.PROCESSING_GUARANTEE_CONFIG, StreamsConfig.AT_LEAST_ONCE);
        
        // Commit interval for exactly-once semantics
        props.put(StreamsConfig.COMMIT_INTERVAL_MS_CONFIG, 1000);

        // Build the topology
        StreamsBuilder builder = new StreamsBuilder();
        
        // Create custom Serde for Tweet objects
        TweetSerde tweetSerde = new TweetSerde();
        
        // Read from input topic
        KStream<String, Tweet> tweetsStream = builder.stream(
            INPUT_TOPIC,
            Consumed.with(Serdes.String(), tweetSerde)
        );

        // Filter negative tweets and process alerts
        KStream<String, String> alertsStream = tweetsStream
            .filter((key, tweet) -> tweet != null && "negative".equalsIgnoreCase(tweet.getAirlineSentiment()))
            .mapValues((tweet) -> {
                String timestamp = LocalDateTime.now().format(formatter);
                String alertMessage = String.format(
                    "[%s] ALERT [%s]: %s",
                    timestamp,
                    tweet.getAirline(),
                    tweet.getText()
                );
                
                // Print to console for real-time monitoring
                System.out.println("\n" + LINE);
                System.out.println("NEGATIVE SENTIMENT DETECTED!");
                System.out.println(LINE);
                System.out.println("Airline: " + tweet.getAirline());
                System.out.println("Tweet ID: " + tweet.getTweetId());
                System.out.println("Text: " + tweet.getText());
                System.out.println("Confidence: " + tweet.getAirlineSentimentConfidence());
                if (tweet.getNegativeReason() != null && !tweet.getNegativeReason().isEmpty()) {
                    System.out.println("Reason: " + tweet.getNegativeReason());
                }
                System.out.println("Time: " + tweet.getTweetCreated());
                System.out.println(LINE + "\n");
                
                return alertMessage;
            });

        // Write alerts to output topic
        alertsStream.to(OUTPUT_TOPIC);

        // Also log statistics
        tweetsStream
            .groupBy((key, tweet) -> tweet != null ? tweet.getAirline() : "unknown")
            .count()
            .toStream()
            .foreach((airline, count) -> {
                if (count % 100 == 0) {
                    System.out.println("[Stats] " + airline + ": " + count + " tweets processed");
                }
            });

        // Build and start the Kafka Streams application
        KafkaStreams streams = new KafkaStreams(builder.build(), props);

        // Add shutdown hook for graceful shutdown
        final CountDownLatch latch = new CountDownLatch(1);
        Runtime.getRuntime().addShutdownHook(new Thread("streams-shutdown-hook") {
            @Override
            public void run() {
                System.out.println("\nShutting down Sentiment Alert Application...");
                streams.close();
                latch.countDown();
            }
        });

        try {
            System.out.println(LINE);
            System.out.println("Starting Sentiment Alert Application (Kafka Streams)");
            System.out.println(LINE);
            System.out.println("Input Topic: " + INPUT_TOPIC);
            System.out.println("Output Topic: " + OUTPUT_TOPIC);
            System.out.println("Bootstrap Servers: " + getBootstrapServers());
            System.out.println(LINE);
            System.out.println("Waiting for tweets... (Press Ctrl+C to stop)\n");
            
            streams.start();
            latch.await();
        } catch (Throwable e) {
            System.err.println("Error in Sentiment Alert Application: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
        
        System.exit(0);
    }

    /**
     * Get Kafka bootstrap servers from environment variable or use default.
     */
    private static String getBootstrapServers() {
        String servers = System.getenv("KAFKA_BOOTSTRAP_SERVERS");
        return servers != null ? servers : "localhost:9092";
    }
}
