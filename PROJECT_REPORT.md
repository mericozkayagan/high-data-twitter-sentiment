# 📄 High-Performance Analysis of Twitter Data
## Lambda Architecture Implementation - Project Report

---

## 👥 Grup Üyeleri

| İsim | Soyisim | Öğrenci Numarası |
|------|---------|------------------|
| Meriç | Özkayağan | [Öğrenci No] |
| [İsim 2] | [Soyisim 2] | [Öğrenci No 2] |
| [İsim 3] | [Soyisim 3] | [Öğrenci No 3] |

> **Not:** Lütfen grup üyelerinin bilgilerini yukarıdaki tabloya ekleyin.

---

## 1. Seçilen Track

### ✅ Track 2A: Apache Kafka Ecosystem

Bu projede **Track 2A - Apache Kafka Ecosystem** seçilmiştir.

| Bileşen | Teknoloji | Açıklama |
|---------|-----------|----------|
| **Processing Framework** | Apache Kafka Streams | Real-time stream processing |
| **Persistence** | Kafka Connect HDFS 3 Sink | Konfigürasyon hazırlandı |
| **Use Case** | Use Case A | Real-Time Airline Complaint Alerting |

### Neden Track 2A Seçildi?

1. **Kolay Kurulum:** Kafka Streams ayrı bir cluster gerektirmez, normal Java uygulaması olarak çalışır
2. **Windows Uyumluluğu:** Apache Flink'e göre Windows ortamında daha az sorun çıkarır
3. **Düşük Latency:** Embedded çalışma modu sayesinde çok düşük gecikme süresi
4. **Kolay Ölçeklendirme:** Daha fazla instance çalıştırarak kolayca scale edilebilir
5. **Entegre Ekosistem:** Kafka ile native entegrasyon, Schema Registry desteği

---

## 2. Sistem Mimarisi

### 2.1 Lambda Architecture Genel Bakış

```
                         ┌─────────────────────────────────────────────────┐
                         │              LAMBDA ARCHITECTURE                 │
                         └─────────────────────────────────────────────────┘

┌──────────────┐         ┌─────────────────┐         ┌──────────────────────┐
│              │         │                 │         │                      │
│  Tweets.csv  │────────▶│  Kafka Topic    │────────▶│  Kafka Streams App   │
│  (Kaggle)    │         │  tweets_topic   │         │  (Real-time Alerts)  │
│              │         │                 │         │                      │
└──────────────┘         └─────────────────┘         └──────────┬───────────┘
       │                                                        │
       │                                                        │
       │ Batch Path                                   Stream Path
       │                                                        │
       ▼                                                        ▼
┌──────────────────┐                               ┌────────────────────────┐
│                  │                               │                        │
│   Apache Spark   │                               │   Console Output +     │
│   (Batch Job)    │                               │   realtime_alerts      │
│                  │                               │   Kafka Topic          │
└────────┬─────────┘                               └────────────────────────┘
         │
         ▼
┌──────────────────┐
│                  │
│  Parquet/CSV     │
│  (Local/HDFS)    │
│                  │
└──────────────────┘
         │
         ▼
┌──────────────────┐
│                  │
│   Apache Hive    │
│   (Data Catalog) │
│                  │
└──────────────────┘
```

### 2.2 Bileşen Detayları

#### Docker Ortamı (docker-compose.yml)

| Servis | Port | Açıklama |
|--------|------|----------|
| Zookeeper | 2181 | Kafka koordinasyonu |
| Kafka | 9092, 29092 | Message broker |
| Schema Registry | 8081 | Avro şema yönetimi |
| Kafka UI | 8080 | Web arayüzü (monitoring) |

#### Kafka Topics

| Topic | Partitions | Açıklama |
|-------|------------|----------|
| `tweets_topic` | 3 | Ham tweet verileri |
| `realtime_alerts` | 3 | Negatif sentiment uyarıları |

---

## 3. Uygulama Bileşenleri

### 3.1 Part 1: Batch Processing (Apache Spark)

**Dosya:** `scripts/spark_batch_job.py`

**İşlem Akışı:**
```python
# 1. Tüm Tweets.csv'yi DataFrame olarak yükler
df = spark.read.csv("data/Tweets.csv", header=True, schema=schema)

# 2. Havayolu bazında gruplar
result = df.groupBy("airline").agg(
    count("*").alias("total_tweets"),
    count(when(col("airline_sentiment") == "positive", 1)).alias("positive_count"),
    count(when(col("airline_sentiment") == "negative", 1)).alias("negative_count"),
    count(when(col("airline_sentiment") == "neutral", 1)).alias("neutral_count")
)

# 3. Negatif oranı hesaplar
result = result.withColumn("negative_ratio", 
    col("negative_count") / col("total_tweets")
)

# 4. Sonuçları kaydeder (Parquet/CSV)
result.write.mode("overwrite").parquet(OUTPUT_PATH)
```

**Çıktı Şeması:**
```
airline | total_tweets | positive_count | negative_count | neutral_count | negative_ratio
```

### 3.2 Part 2: Stream Processing (Kafka Streams)

**Dosya:** `src/main/java/com/twitter/streams/SentimentAlertApp.java`

**Use Case A: Real-Time Airline Complaint Alerting**

```java
// Kafka Streams Topology
KStream<String, Tweet> tweetsStream = builder.stream("tweets_topic");

// Negatif sentiment'leri filtrele
tweetsStream
    .filter((key, tweet) -> "negative".equals(tweet.getAirlineSentiment()))
    .peek((key, tweet) -> printAlert(tweet))  // Console'a yazdır
    .mapValues(tweet -> formatAlert(tweet))
    .to("realtime_alerts");  // Yeni topic'e gönder
```

**Özellikler:**
- Custom Serde (TweetSerde) ile JSON serializasyon
- Graceful shutdown (SIGINT handling)
- Hem console hem de Kafka topic çıktısı
- Detailed alert formatting (Airline, Tweet ID, Text, Confidence, Reason, Time)

### 3.3 Kafka Producer

**Dosya:** `scripts/kafka_producer.py`

**İşleyiş:**
```python
# 1. CSV dosyasını satır satır okur
with open('data/Tweets.csv', 'r') as f:
    reader = csv.reader(f)
    
    for row in reader:
        # 2. Her satırı JSON formatına çevirir
        tweet = parse_tweet_row(row)
        
        # 3. Kafka topic'ine gönderir
        producer.send('tweets_topic', key=tweet_id, value=tweet)
        
        # 4. Gerçekçi simülasyon için 100ms bekler
        time.sleep(0.1)
```

---

## 4. Derleme ve Çalıştırma Talimatları

### 4.1 Gereksinimler

| Yazılım | Versiyon | Amaç |
|---------|----------|------|
| Python | 3.8+ | Producer, Spark Job |
| Java | 11+ (17 önerilen) | Kafka Streams |
| Maven | 3.6+ | Java build |
| Docker Desktop | 20+ | Kafka ortamı |

### 4.2 Kurulum

```powershell
# 1. Proje dizinine git
cd 4-sinif\high-data

# 2. Python ortamını kur
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
pip install kafka-python-ng  # Python 3.12+ için

# 3. Java uygulamasını derle
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot"
$env:Path = "$env:JAVA_HOME\bin;C:\tools\apache-maven-3.9.6\bin;$env:Path"
mvn clean package -DskipTests

# 4. Tweets.csv dosyasını indir ve data\ klasörüne koy
# https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment
```

### 4.3 Çalıştırma

```powershell
# Terminal 1: Kafka'yı başlat
docker-compose up -d

# Topic'leri oluştur (bir kez)
docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic tweets_topic --partitions 3 --replication-factor 1
docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic realtime_alerts --partitions 3 --replication-factor 1

# Terminal 2: Kafka Streams uygulamasını başlat
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
cd 4-sinif\high-data
java -cp "target\twitter-sentiment-analysis-1.0.0.jar" com.twitter.streams.SentimentAlertApp

# Terminal 3: Producer'ı çalıştır
cd 4-sinif\high-data
.\venv\Scripts\python.exe .\scripts\kafka_producer.py

# Terminal 4: Spark batch job'ı çalıştır
$env:HADOOP_HOME = "C:\hadoop"  # Windows için
.\venv\Scripts\python.exe .\scripts\spark_batch_job.py
```

---

## 5. Sonuçlar

### 5.1 Kafka UI - Ana Sayfa

Kafka UI (http://localhost:8080) üzerinden cluster durumu ve topic'ler izlenebilir.

![Kafka UI Ana Sayfa](images/main-page.jfif)

### 5.2 Tweets Topic

Producer tarafından gönderilen tweet mesajları `tweets_topic`'te görülebilir.

![Tweets Topic](images/tweets-topic.jfif)

### 5.3 Kafka Streams Console Çıktısı (Real-Time Alerts)

Negatif sentiment tespit edildiğinde konsola yazdırılan uyarı örnekleri:

```
================================================================================
NEGATIVE SENTIMENT DETECTED!
================================================================================
Airline: United
Tweet ID: 569411383265075203
Text: @united new 737 plane; wifi: not working. Entertainment: non existent. 
      New Seats: seriously uncomfortable. Really? #unitedfail UA1550
Confidence: 1.0
Reason: Bad Flight
Time: 2015-02-22 00:20:27 -0800
================================================================================

================================================================================
NEGATIVE SENTIMENT DETECTED!
================================================================================
Airline: United
Tweet ID: 569415076400242688
Text: @united I bought a ticket with a price that was published by mistake 
      and now I got an email that indicates United Cancelled my ticket! Why?
Confidence: 1.0
Reason: Flight Booking Problems
Time: 2015-02-22 00:35:08 -0800
================================================================================

================================================================================
NEGATIVE SENTIMENT DETECTED!
================================================================================
Airline: Virgin America
Tweet ID: 569262225900359680
Text: @VirginAmerica Your website is down and I'm trying to check in!
Confidence: 1.0
Reason: Customer Service Issue
Time: 2015-02-21 14:27:45 -0800
================================================================================
```

### 5.4 Kafka Producer Console Çıktısı

```
============================================================
🐦 Twitter Kafka Producer
============================================================
Timestamp: 2025-12-10 21:39:16
✅ Connected to Kafka at localhost:9092

📂 Reading tweets from: data/Tweets.csv
📤 Publishing to topic: tweets_topic
⏱️  Message delay: 0.1s
------------------------------------------------------------
📊 Sent: 100 tweets | Rate: 9.8 msg/s | Negative: 35
📊 Sent: 200 tweets | Rate: 9.7 msg/s | Negative: 83
📊 Sent: 300 tweets | Rate: 9.7 msg/s | Negative: 120
📊 Sent: 400 tweets | Rate: 9.7 msg/s | Negative: 166
...
📊 Sent: 2000 tweets | Rate: 9.7 msg/s | Negative: 1250
```

### 5.5 Spark Batch Job Sonuçları

#### Console Çıktısı

```
================================================================================
🚀 APACHE SPARK BATCH PROCESSING JOB
   Twitter Airline Sentiment Analysis
================================================================================
Timestamp: 2025-12-10 21:42:21
Spark version: 3.5.0

📂 Loading data from CSV: data/Tweets.csv
📊 Total records loaded: 14,640
🔄 Performing sentiment aggregation by airline...

================================================================================
📊 AIRLINE SENTIMENT ANALYSIS RESULTS
================================================================================
+--------------+------------+--------------+--------------+-------------+--------------+
|airline       |total_tweets|positive_count|negative_count|neutral_count|negative_ratio|
+--------------+------------+--------------+--------------+-------------+--------------+
|United        |3822        |492           |2633          |697          |0.6889        |
|US Airways    |2913        |269           |2263          |381          |0.7769        |
|American      |2759        |336           |1960          |463          |0.7104        |
|Southwest     |2420        |570           |1186          |664          |0.4901        |
|Delta         |2222        |544           |955           |723          |0.4298        |
|Virgin America|504         |152           |181           |171          |0.3591        |
+--------------+------------+--------------+--------------+-------------+--------------+

📈 DETAILED STATISTICS:
--------------------------------------------------------------------------------
✈️  United
   Total Tweets: 3,822 (26.1% of all tweets)
   Positive: 492 (12.9%)
   Negative: 2,633 (68.9%)
   Neutral:  697 (18.2%)
   Negative Ratio: 0.6889

✈️  US Airways
   Total Tweets: 2,913 (19.9% of all tweets)
   Positive: 269 (9.2%)
   Negative: 2,263 (77.7%)
   Neutral:  381 (13.1%)
   Negative Ratio: 0.7769

✈️  American
   Total Tweets: 2,759 (18.8% of all tweets)
   Positive: 336 (12.2%)
   Negative: 1,960 (71.0%)
   Neutral:  463 (16.8%)
   Negative Ratio: 0.7104

✈️  Southwest
   Total Tweets: 2,420 (16.5% of all tweets)
   Positive: 570 (23.6%)
   Negative: 1,186 (49.0%)
   Neutral:  664 (27.4%)
   Negative Ratio: 0.4901

✈️  Delta
   Total Tweets: 2,222 (15.2% of all tweets)
   Positive: 544 (24.5%)
   Negative: 955 (43.0%)
   Neutral:  723 (32.5%)
   Negative Ratio: 0.4298

✈️  Virgin America
   Total Tweets: 504 (3.4% of all tweets)
   Positive: 152 (30.2%)
   Negative: 181 (35.9%)
   Neutral:  171 (33.9%)
   Negative Ratio: 0.3591

================================================================================
📊 TOTAL TWEETS ANALYZED: 14,640
================================================================================
💾 Results saved to: output/batch_results_csv/batch_results.csv

⏱️  Total execution time: 0:00:11.177681
✅ Spark session closed.
```

#### batch_airline_sentiment Tablosu (Batch Sonuçları)

```csv
airline,total_tweets,positive_count,negative_count,neutral_count,negative_ratio
United,3822,492,2633,697,0.6889
US Airways,2913,269,2263,381,0.7769
American,2759,336,1960,463,0.7104
Southwest,2420,570,1186,664,0.4901
Delta,2222,544,955,723,0.4298
Virgin America,504,152,181,171,0.3591
```

### 5.6 Hive Tabloları (SQL Sorguları)

> **Not:** Yerel Windows ortamında HDFS kurulu olmadığından, Hive tabloları simüle edilmiştir. 
> Gerçek HDFS ortamında aşağıdaki sorgular çalıştırılacaktır.

#### 1. tweets_raw_csv (Raw Data)

```sql
SELECT * FROM tweets_raw_csv LIMIT 10;
```

| tweet_id | airline_sentiment | airline | retweet_count | text |
|----------|-------------------|---------|---------------|------|
| 570306133677760513 | neutral | Virgin America | 0 | @VirginAmerica What @dhepburn said. |
| 570301130888122368 | positive | Virgin America | 0 | @VirginAmerica plus you've added commercials... |
| 570301083672813571 | neutral | Virgin America | 0 | @VirginAmerica I didn't today... Must mean... |
| 570301031407624196 | negative | Virgin America | 0 | @VirginAmerica it's really aggressive to blast... |
| ... | ... | ... | ... | ... |

#### 2. tweets_stream_avro (Stream-Sunk Data)

```sql
SELECT * FROM tweets_stream_avro LIMIT 10;
```

> Bu tablo, Kafka Connect HDFS Sink tarafından `tweets_topic`'ten okunan verilerle doldurulur.
> Avro formatında, tarih bazlı partition'lı olarak kaydedilir.

#### 3. batch_airline_sentiment (Batch Results)

```sql
SELECT * FROM batch_airline_sentiment;
```

| airline | total_tweets | positive_count | negative_count | neutral_count | negative_ratio |
|---------|--------------|----------------|----------------|---------------|----------------|
| United | 3822 | 492 | 2633 | 697 | 0.6889 |
| US Airways | 2913 | 269 | 2263 | 381 | 0.7769 |
| American | 2759 | 336 | 1960 | 463 | 0.7104 |
| Southwest | 2420 | 570 | 1186 | 664 | 0.4901 |
| Delta | 2222 | 544 | 955 | 723 | 0.4298 |
| Virgin America | 504 | 152 | 181 | 171 | 0.3591 |

---

## 6. Tartışma (Discussion)

### 6.1 Karşılaşılan Zorluklar

#### Zorluk 1: Windows Ortamında Kafka ve Spark Kurulumu

**Problem:** Windows'ta native Kafka ve Spark kurulumu karmaşıktır. Özellikle HADOOP_HOME ve winutils.exe gereksinimleri sorun çıkarmaktadır.

**Çözüm:** 
- Kafka ekosistemi için Docker Compose kullanıldı
- Spark için Parquet yerine CSV fallback mekanizması eklendi
- `kafka-python-ng` paketi kullanıldı (Python 3.12+ uyumluluğu için)

#### Zorluk 2: CSV Parsing

**Problem:** Tweet metinlerinde virgül, tırnak işaretleri ve çok satırlı içerik bulunması CSV parsing'i zorlaştırdı.

**Çözüm:** 
- Spark'ta `multiLine=true` ve proper quote handling kullanıldı
- Custom CSV parsing logic implementasyonu yapıldı

#### Zorluk 3: Kafka-Python Uyumluluk

**Problem:** Standart `kafka-python` paketi Python 3.12+ ile uyumsuz (`distutils` modülü kaldırıldı).

**Çözüm:** Aktif olarak bakımı yapılan `kafka-python-ng` fork'u kullanıldı.

#### Zorluk 4: JSON Serializasyon

**Problem:** Kafka Streams'te Tweet objelerinin serialize/deserialize edilmesi.

**Çözüm:** Custom Serde (TweetSerde) implementasyonu yapıldı - Jackson JSON kütüphanesi kullanıldı.

### 6.2 Track 2A Seçim Gerekçesi

**Apache Kafka Streams** seçilmesinin sebepleri:

1. **Embedded Architecture:** Ayrı bir cluster gerektirmez, standart Java uygulaması olarak çalışır
2. **Exactly-Once Semantics:** Kafka ile native entegrasyon sayesinde exactly-once processing garantisi
3. **State Management:** Built-in state store desteği (RocksDB)
4. **Windows Uyumluluğu:** Flink'e göre Windows ortamında daha az sorun
5. **Öğrenme Eğrisi:** DSL API'si sezgisel ve öğrenmesi kolay
6. **Operasyonel Basitlik:** Ayrı resource manager (YARN, Mesos) gerektirmez

### 6.3 Sonuç ve Değerlendirme

Bu projede başarıyla:

- ✅ Lambda mimarisi implementasyonu yapıldı
- ✅ Apache Spark ile batch processing gerçekleştirildi (14,640 tweet analizi)
- ✅ Kafka Streams ile real-time stream processing yapıldı
- ✅ Negatif sentiment detection ve alerting sistemi kuruldu
- ✅ Docker ortamında Kafka ekosistemi çalıştırıldı

**İstatistikler:**
- Toplam tweet: 14,640
- 6 havayolu analiz edildi
- En yüksek negatif oran: US Airways (%77.7)
- En düşük negatif oran: Virgin America (%35.9)
- Stream processing hızı: ~9.7 msg/s

---

## 7. Proje Yapısı

```
high-data/
├── src/main/java/com/twitter/streams/    # Java Kafka Streams uygulamaları
│   ├── Tweet.java                        # Tweet veri modeli
│   ├── TweetSerde.java                   # Kafka Serde (Serializer/Deserializer)
│   ├── SentimentAlertApp.java            # Use Case A: Negatif tweet uyarıları
│   └── RetweetCounterApp.java            # Use Case B: Pencereli retweet sayacı
│
├── scripts/
│   ├── kafka_producer.py                 # Python Kafka Producer
│   ├── spark_batch_job.py                # PySpark Batch İşleme
│   ├── hive_tables.sql                   # Hive tablo tanımları
│   └── *.bat                             # Windows batch script'leri
│
├── config/
│   ├── application.properties            # Uygulama ayarları
│   └── kafka-connect-hdfs.properties     # Kafka Connect HDFS sink config
│
├── data/                                 # Tweets.csv veri dosyası
├── output/                               # Spark batch çıktıları
├── images/                               # Ekran görüntüleri
├── docker-compose.yml                    # Kafka Docker ortamı
├── pom.xml                               # Maven build dosyası
├── requirements.txt                      # Python bağımlılıkları
└── PROJECT_REPORT.md                     # Bu rapor
```

---

## 8. Referanslar

1. **Dataset:** [Kaggle - Twitter US Airline Sentiment](https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment)
2. **Apache Kafka Streams:** [kafka.apache.org/documentation/streams](https://kafka.apache.org/documentation/streams/)
3. **Apache Spark SQL Guide:** [spark.apache.org/docs/latest/sql-programming-guide.html](https://spark.apache.org/docs/latest/sql-programming-guide.html)
4. **Apache Hive:** [hive.apache.org](https://hive.apache.org/)
5. **Confluent Platform:** [docs.confluent.io](https://docs.confluent.io/)

---

**Rapor Tarihi:** Aralık 2025

**Ders:** High-Performance Data Processing (4. Sınıf)
