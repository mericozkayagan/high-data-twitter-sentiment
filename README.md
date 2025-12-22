# 🐦 Twitter Airline Sentiment Analysis

**High-Performance Data Processing Pipeline - Lambda Architecture**

Bu proje, Apache Spark (batch) ve Apache Kafka Streams (stream) kullanarak Twitter havayolu sentiment verilerini analiz eden bir Lambda mimarisi implementasyonudur.

---

## 📋 Proje Özeti

| Bileşen | Teknoloji | Açıklama |
|---------|-----------|----------|
| **Part 1: Batch** | Apache Spark (PySpark) | Havayolu sentiment analizi |
| **Part 2: Stream** | Kafka Streams (Java) | Gerçek zamanlı negatif tweet uyarıları |
| **Data Catalog** | Apache Hive | SQL tabanlı veri yönetimi |
| **Message Broker** | Apache Kafka | Stream veri akışı |

**Seçilen Track:** Track 2A - Apache Kafka Ecosystem

**Grup Üyeleri:**
- Meriç Özkayagan (05230001155)
- Mustafa Yiğit Güzel (05210000209)
- Fatma Verda Yüksel (05210000299)

---

## 🚀 Hızlı Başlangıç

### Gereksinimler

- **Python 3.8+**: [python.org](https://www.python.org/downloads/)
- **Java 11+**: [adoptium.net](https://adoptium.net/)
- **Maven 3.6+**: [maven.apache.org](https://maven.apache.org/download.cgi)
- **Docker Desktop**: [docker.com](https://www.docker.com/products/docker-desktop)

---

### Windows

#### Kurulum

```powershell
# 1. Proje dizinine git
cd 4-sinif\high-data

# 2. Ortamı kur
scripts\setup_environment.bat

# 3. Tweets.csv'yi indir ve data\ klasörüne koy
# https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment
```

#### Çalıştırma

```powershell
# 1. Kafka'yı başlat (Docker)
scripts\start_kafka.bat

# 2. Kafka topic'lerini oluştur
scripts\create_topics.bat

# 3. Terminal 1: Kafka Streams uygulamasını başlat
scripts\run_streams_app.bat

# 4. Terminal 2: Producer'ı çalıştır (verileri stream et)
scripts\run_producer.bat

# 5. Spark batch job'ı çalıştır
scripts\run_spark_job.bat
```

---

### Mac / Linux

#### Kurulum

```bash
# 1. Proje dizinine git
cd 4-sinif/high-data

# 2. Script'lere execute izni ver
chmod +x scripts/*.sh

# 3. Ortamı kur
./scripts/setup_environment.sh

# 4. Tweets.csv'yi indir ve data/ klasörüne koy
# https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment
```

#### Çalıştırma

```bash
# 1. Kafka'yı başlat (Docker)
./scripts/start_kafka.sh

# 2. Kafka topic'lerini oluştur
./scripts/create_topics.sh

# 3. Terminal 1: Kafka Streams uygulamasını başlat
./scripts/run_streams_app.sh

# 4. Terminal 2: Producer'ı çalıştır (verileri stream et)
./scripts/run_producer.sh

# 5. Spark batch job'ı çalıştır
./scripts/run_spark_job.sh

# Kafka'yı durdurmak için:
./scripts/stop_kafka.sh
```

---

## 📁 Proje Yapısı

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
│   ├── setup_environment.bat/.sh          # Ortam kurulumu (Windows/Mac)
│   ├── start_kafka.bat/.sh                # Kafka başlatma (Windows/Mac)
│   ├── create_topics.bat/.sh              # Topic oluşturma (Windows/Mac)
│   ├── run_producer.bat/.sh               # Producer çalıştırma (Windows/Mac)
│   ├── run_spark_job.bat/.sh              # Spark job çalıştırma (Windows/Mac)
│   ├── run_streams_app.bat/.sh            # Kafka Streams çalıştırma (Windows/Mac)
│   ├── build_java.bat/.sh                 # Java build (Windows/Mac)
│   └── stop_kafka.sh                      # Kafka durdurma (Mac/Linux)
│
├── config/
│   ├── application.properties            # Uygulama ayarları
│   └── kafka-connect-hdfs.properties     # Kafka Connect HDFS sink
│
├── data/                                 # Tweets.csv buraya konur
├── output/                               # Spark çıktıları
├── docker-compose.yml                    # Kafka Docker ortamı
├── pom.xml                               # Maven build dosyası
└── requirements.txt                      # Python bağımlılıkları
```

---

## 🔧 Bileşenler

### Part 1: Batch Processing (Apache Spark)

**Dosya:** `scripts/spark_batch_job.py`

Spark job'ı şunları yapar:
1. `Tweets.csv` dosyasını okur
2. Havayolu başına sentiment aggregation yapar
3. Negatif oran hesaplar (`negative_count / total_tweets`)
4. Sonuçları Parquet formatında kaydeder

**Çalıştırma:**
```powershell
scripts\run_spark_job.bat
```

**Çıktı Şeması:**
```
airline | total_tweets | positive_count | negative_count | neutral_count | negative_ratio
```

---

### Part 2: Stream Processing (Kafka Streams)

**Dosya:** `src/main/java/com/twitter/streams/SentimentAlertApp.java`

**Use Case A: Real-Time Airline Complaint Alerting**
- Negatif sentiment'li tweet'leri filtreler
- Konsola uyarı mesajı yazdırır
- `realtime_alerts` topic'ine yazar

**Örnek Çıktı:**
```
================================================================================
🚨 NEGATIVE SENTIMENT DETECTED!
================================================================================
Airline: United
Tweet ID: 570306133677760513
Text: @united you lost my luggage again!
Confidence: 1.0
Reason: Lost Luggage
================================================================================
```

---

### Kafka Producer

**Dosya:** `scripts/kafka_producer.py`

CSV dosyasını okur ve Kafka'ya stream eder:
- Her tweet JSON olarak `tweets_topic`'e gönderilir
- 100ms gecikme ile gerçekçi simülasyon
- İstatistik özeti gösterir

---

## 📊 Hive Tabloları

### 1. Raw Data (CSV)
```sql
CREATE EXTERNAL TABLE tweets_raw_csv (...)
STORED AS TEXTFILE
LOCATION '/project/raw/';
```

### 2. Stream Data (Avro)
```sql
CREATE EXTERNAL TABLE tweets_stream_avro (...)
PARTITIONED BY (dt STRING)
STORED AS AVRO
LOCATION '/project/streamed_tweets_avro/';
```

### 3. Batch Results (Parquet)
```sql
CREATE EXTERNAL TABLE batch_airline_sentiment (...)
STORED AS PARQUET
LOCATION '/project/batch_results_parquet/';
```

---

## 🐳 Docker Ortamı

`docker-compose.yml` aşağıdaki servisleri içerir:

| Servis | Port | Açıklama |
|--------|------|----------|
| Zookeeper | 2181 | Kafka koordinasyonu |
| Kafka | 9092 | Message broker |
| Schema Registry | 8081 | Avro şema yönetimi |
| Kafka UI | 8080 | Web arayüzü |
| PostgreSQL | 5432 | Hive Metastore veritabanı |
| Hive Metastore | 9083 | Hive metadata yönetimi |
| HiveServer2 | 10000, 10002 | Hive SQL server ve Web UI |

**Başlatma:**
```powershell
docker-compose up -d
```

**Durdurma:**
```powershell
docker-compose down
```

**Hive Tablolarını Oluşturma:**
```bash
# HiveServer2'ye bağlan
docker exec -it hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p ""

# SQL dosyasını çalıştır
docker exec -i hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p "" < scripts/hive_tables.sql
```

---

## 📈 Beklenen Sonuçlar

Dataset istatistikleri (yaklaşık):
- Toplam tweet: ~14,640
- Havayolları: 6 (United, US Airways, American, Southwest, Delta, Virgin America)
- Sentiment dağılımı: ~63% negatif, ~21% nötr, ~16% pozitif

---

## 🛠️ Sorun Giderme

### Kafka bağlantı hatası
```
Docker Desktop'ın çalıştığından emin olun:
docker info
```

### Python modül bulunamadı
```
Virtual environment'ı aktifleştirin:
venv\Scripts\activate.bat
pip install -r requirements.txt
```

### Maven build hatası
```
Java 11+ kurulu olduğundan emin olun:
java -version
```

---

## 📚 Kaynaklar

- [Kaggle Dataset](https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment)
- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [Kafka Streams Documentation](https://kafka.apache.org/documentation/streams/)
- [Apache Hive Documentation](https://hive.apache.org/)

---

## 👨‍💻 Geliştirici

4. Sınıf - High-Performance Data Processing Dersi Projesi

