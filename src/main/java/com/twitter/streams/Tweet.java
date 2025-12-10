package com.twitter.streams;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Tweet data model for Kafka Streams processing.
 * Maps to the Twitter US Airline Sentiment dataset schema.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class Tweet {
    
    @JsonProperty("tweet_id")
    private String tweetId;
    
    @JsonProperty("airline_sentiment")
    private String airlineSentiment;
    
    @JsonProperty("airline_sentiment_confidence")
    private Double airlineSentimentConfidence;
    
    @JsonProperty("negativereason")
    private String negativeReason;
    
    @JsonProperty("negativereason_confidence")
    private Double negativeReasonConfidence;
    
    @JsonProperty("airline")
    private String airline;
    
    @JsonProperty("name")
    private String name;
    
    @JsonProperty("retweet_count")
    private Integer retweetCount;
    
    @JsonProperty("text")
    private String text;
    
    @JsonProperty("tweet_created")
    private String tweetCreated;
    
    @JsonProperty("tweet_location")
    private String tweetLocation;
    
    @JsonProperty("user_timezone")
    private String userTimezone;

    // Default constructor for JSON deserialization
    public Tweet() {}

    // Getters and Setters
    public String getTweetId() {
        return tweetId;
    }

    public void setTweetId(String tweetId) {
        this.tweetId = tweetId;
    }

    public String getAirlineSentiment() {
        return airlineSentiment;
    }

    public void setAirlineSentiment(String airlineSentiment) {
        this.airlineSentiment = airlineSentiment;
    }

    public Double getAirlineSentimentConfidence() {
        return airlineSentimentConfidence;
    }

    public void setAirlineSentimentConfidence(Double airlineSentimentConfidence) {
        this.airlineSentimentConfidence = airlineSentimentConfidence;
    }

    public String getNegativeReason() {
        return negativeReason;
    }

    public void setNegativeReason(String negativeReason) {
        this.negativeReason = negativeReason;
    }

    public Double getNegativeReasonConfidence() {
        return negativeReasonConfidence;
    }

    public void setNegativeReasonConfidence(Double negativeReasonConfidence) {
        this.negativeReasonConfidence = negativeReasonConfidence;
    }

    public String getAirline() {
        return airline;
    }

    public void setAirline(String airline) {
        this.airline = airline;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getRetweetCount() {
        return retweetCount;
    }

    public void setRetweetCount(Integer retweetCount) {
        this.retweetCount = retweetCount;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getTweetCreated() {
        return tweetCreated;
    }

    public void setTweetCreated(String tweetCreated) {
        this.tweetCreated = tweetCreated;
    }

    public String getTweetLocation() {
        return tweetLocation;
    }

    public void setTweetLocation(String tweetLocation) {
        this.tweetLocation = tweetLocation;
    }

    public String getUserTimezone() {
        return userTimezone;
    }

    public void setUserTimezone(String userTimezone) {
        this.userTimezone = userTimezone;
    }

    @Override
    public String toString() {
        return "Tweet{" +
                "tweetId='" + tweetId + '\'' +
                ", airline='" + airline + '\'' +
                ", sentiment='" + airlineSentiment + '\'' +
                ", text='" + (text != null && text.length() > 50 ? text.substring(0, 50) + "..." : text) + '\'' +
                '}';
    }
}

