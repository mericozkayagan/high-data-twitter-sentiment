package com.twitter.streams;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.*;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Properties;
import java.util.concurrent.CountDownLatch;

/**
 * Real-Time Retweet Counter Application (Windowed)
 * 
 * Use Case B: Use a Tumbling Window (1 minute). For each window,
 * sum the retweet_count grouped by airline. At the end of each minute,
 * print the total retweets for each airline in that window.
 * 
 * Track 2A: Apache Kafka Streams
 */
public class RetweetCounterApp {

    private static final String INPUT_TOPIC = "tweets_topic";
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
    private static final String LINE = "================================================================================";

    public static void main(String[] args) {
        // Kafka Streams configuration
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "retweet-counter-app");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, getBootstrapServers());
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
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

        // Group by airline and count retweets in 1-minute tumbling windows
        tweetsStream
            .filter((key, tweet) -> tweet != null && tweet.getAirline() != null)
            .groupBy(
                (key, tweet) -> tweet.getAirline(),
                Grouped.with(Serdes.String(), tweetSerde)
            )
            .windowedBy(TimeWindows.of(Duration.ofMinutes(1)))
            .aggregate(
                () -> 0L,  // Initializer
                (airline, tweet, aggregate) -> {
                    int retweets = tweet.getRetweetCount() != null ? tweet.getRetweetCount() : 0;
                    return aggregate + retweets;
                },
                Materialized.with(Serdes.String(), Serdes.Long())
            )
            .toStream()
            .foreach((windowedAirline, retweetCount) -> {
                String windowStart = LocalDateTime.now().format(formatter);
                System.out.println(String.format(
                    "[%s] %s: %d retweets",
                    windowStart,
                    windowedAirline.key(),
                    retweetCount
                ));
            });

        // Build and start the Kafka Streams application
        KafkaStreams streams = new KafkaStreams(builder.build(), props);

        // Add shutdown hook
        final CountDownLatch latch = new CountDownLatch(1);
        Runtime.getRuntime().addShutdownHook(new Thread("streams-shutdown-hook") {
            @Override
            public void run() {
                System.out.println("\nShutting down Retweet Counter Application...");
                streams.close();
                latch.countDown();
            }
        });

        try {
            System.out.println(LINE);
            System.out.println("Starting Retweet Counter Application (Windowed)");
            System.out.println(LINE);
            System.out.println("Input Topic: " + INPUT_TOPIC);
            System.out.println("Window Size: 1 minute (Tumbling)");
            System.out.println("Bootstrap Servers: " + getBootstrapServers());
            System.out.println(LINE);
            System.out.println("Waiting for tweets... (Press Ctrl+C to stop)\n");
            
            streams.start();
            latch.await();
        } catch (Throwable e) {
            System.err.println("Error in Retweet Counter Application: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
        
        System.exit(0);
    }

    private static String getBootstrapServers() {
        String servers = System.getenv("KAFKA_BOOTSTRAP_SERVERS");
        return servers != null ? servers : "localhost:9092";
    }
}
