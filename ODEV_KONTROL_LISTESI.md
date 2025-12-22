# ✅ Ödev Kontrol Listesi

Bu doküman, ödev tesliminden önce kontrol edilmesi gereken tüm öğeleri içerir.

---

## 📋 Ödev Gereksinimleri (homework.md'den)

### 1. ✅ Source Code

#### Part 1: Spark Batch Job
- [x] `scripts/spark_batch_job.py` - Var ✅
- [x] Çalışıyor mu? - Kontrol edildi ✅

#### Kafka Producer Script
- [x] `scripts/kafka_producer.py` - Var ✅
- [x] Çalışıyor mu? - Kontrol edildi ✅

#### Part 2: Kafka Streams Application
- [x] `src/main/java/com/twitter/streams/SentimentAlertApp.java` - Var ✅
- [x] `src/main/java/com/twitter/streams/Tweet.java` - Var ✅
- [x] `src/main/java/com/twitter/streams/TweetSerde.java` - Var ✅
- [x] JAR dosyası derlenmiş mi? (`target/twitter-sentiment-analysis-1.0.0.jar`) - Var ✅

---

### 2. ✅ Configuration Files

- [x] `config/kafka-connect-hdfs.properties` - Var ✅
- [x] `config/application.properties` - Var ✅
- [x] `docker-compose.yml` - Var ✅
- [x] `pom.xml` - Var ✅
- [x] `requirements.txt` - Var ✅

---

### 3. ✅ Project Report

#### 3.1 Temel Gereksinimler
- [x] Track seçimi açık mı? (Track 2A) - ✅ PROJECT_REPORT.md'de var
- [x] Sistem mimarisi açıklanmış mı? - ✅ Var
- [x] Derleme ve çalıştırma talimatları var mı? - ✅ Var

#### 3.2 Results Bölümü

**Stream Processing Screenshots:**
- [ ] Kafka Streams console output screenshot'ı eklendi mi?
- [ ] Producer console output screenshot'ı eklendi mi?
- [ ] Kafka UI'dan topic'ler screenshot'ı eklendi mi?
- [ ] Consumer groups screenshot'ı eklendi mi?

**Hive Query Screenshots (ZORUNLU):**
- [ ] `SELECT * FROM tweets_raw_csv LIMIT 10;` screenshot'ı eklendi mi?
- [ ] `SELECT * FROM tweets_stream_avro LIMIT 10;` screenshot'ı eklendi mi?
- [ ] `SELECT * FROM batch_airline_sentiment;` screenshot'ı eklendi mi? ⭐ EN ÖNEMLİSİ

#### 3.3 Discussion Bölümü
- [x] Karşılaşılan zorluklar açıklanmış mı? - ✅ Var
- [x] Track seçim gerekçesi açıklanmış mı? - ✅ Var
- [x] Sonuç ve değerlendirme var mı? - ✅ Var

---

### 4. ⚠️ Eksik Olabilecekler

#### 4.1 PROJECT_REPORT.md'de Doldurulması Gerekenler
- [ ] Grup üyeleri bilgileri dolduruldu mu?
  - Öğrenci numaraları
  - İsimler (eğer grup çalışmasıysa)

#### 4.2 Screenshot'ların Report'a Eklenmesi
- [ ] Screenshot'lar `images/` klasörüne kopyalandı mı?
- [ ] PROJECT_REPORT.md'de screenshot referansları güncellendi mi?
- [ ] Screenshot'lar doğru sırayla eklendi mi?

#### 4.3 Hive Query Sonuçları
- [ ] Hive tabloları oluşturuldu mu? - ✅ Yapıldı
- [ ] Hive query'leri çalıştırıldı mı? - Kontrol edilmeli
- [ ] Query sonuçları screenshot olarak alındı mı? - Kontrol edilmeli

---

## 🔍 Detaylı Kontrol

### Screenshot Kontrolü

**Zorunlu Screenshot'lar:**
1. ✅ Kafka Topics Listesi
2. ✅ tweets_topic Messages (en az 5 mesaj)
3. ✅ realtime_alerts Messages (en az 3 alert)
4. ✅ Kafka Streams Console Output
5. ✅ Spark Batch Job Console Output
6. ⚠️ Hive Query: tweets_raw_csv
7. ⚠️ Hive Query: tweets_stream_avro
8. ⚠️ Hive Query: batch_airline_sentiment ⭐

**Screenshot Dosya Adları Önerisi:**
```
screenshots/
├── 01_kafka_topics_list.png
├── 02_tweets_topic_messages.png
├── 03_realtime_alerts_messages.png
├── 04_kafka_streams_console.png
├── 05_spark_batch_console.png
├── 06_hive_tweets_raw_csv.png
├── 07_hive_tweets_stream_avro.png
└── 08_hive_batch_airline_sentiment.png
```

---

### Kod Kontrolü

#### Spark Batch Job
```bash
# Çalıştırılıp test edildi mi?
python scripts/spark_batch_job.py
```

#### Kafka Producer
```bash
# Çalıştırılıp test edildi mi?
python scripts/kafka_producer.py
```

#### Kafka Streams
```bash
# JAR çalıştırılıp test edildi mi?
java -jar target/twitter-sentiment-analysis-1.0.0.jar
```

---

### Hive Query Kontrolü

#### Query'leri Çalıştır ve Kontrol Et:
```bash
# Beeline'a bağlan
docker exec -it hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p ""

# Query 1: tweets_raw_csv
SELECT * FROM tweets_raw_csv LIMIT 10;

# Query 2: tweets_stream_avro
SELECT * FROM tweets_stream_avro LIMIT 10;

# Query 3: batch_airline_sentiment (ZORUNLU)
SELECT * FROM batch_airline_sentiment;
```

**Kontrol:**
- [ ] Her query sonuç döndürüyor mu?
- [ ] Sonuçlar mantıklı mı?
- [ ] Screenshot'lar alındı mı?

---

## 📦 Final Zip Dosyası Hazırlığı

### Zip İçeriği Kontrolü

```
project-submission.zip
├── src/                          ✅ Java kaynak kodları
│   └── main/java/com/twitter/streams/
├── scripts/                      ✅ Python script'leri
│   ├── kafka_producer.py
│   ├── spark_batch_job.py
│   └── hive_tables.sql
├── config/                       ✅ Konfigürasyon dosyaları
│   ├── kafka-connect-hdfs.properties
│   └── application.properties
├── pom.xml                       ✅ Maven build dosyası
├── requirements.txt              ✅ Python bağımlılıkları
├── docker-compose.yml           ✅ Docker ortamı
├── PROJECT_REPORT.md             ✅ Ödev raporu
├── screenshots/                  ⚠️ Screenshot'lar (eklenmeli)
│   ├── 01_kafka_topics_list.png
│   ├── 02_tweets_topic_messages.png
│   ├── 03_realtime_alerts_messages.png
│   ├── 04_kafka_streams_console.png
│   ├── 05_spark_batch_console.png
│   ├── 06_hive_tweets_raw_csv.png
│   ├── 07_hive_tweets_stream_avro.png
│   └── 08_hive_batch_airline_sentiment.png
└── README.md                     ✅ (Opsiyonel ama önerilen)
```

### Zip Oluşturma Komutu

```bash
cd /Users/nav-meric/meric-ozkayagan/4.sinif/high-data-twitter-sentiment

# Gereksiz dosyaları hariç tutarak zip oluştur
zip -r project-submission.zip \
  src/ \
  scripts/ \
  config/ \
  pom.xml \
  requirements.txt \
  docker-compose.yml \
  PROJECT_REPORT.md \
  screenshots/ \
  -x "*.class" "*.jar" "venv/*" "target/*" "data/*" "output/*" "logs/*" ".git/*"
```

---

## ✅ Son Kontrol Adımları

### 1. Kod Kontrolü
- [ ] Tüm kod dosyaları mevcut mu?
- [ ] Kod çalışıyor mu?
- [ ] Hata mesajı var mı?

### 2. Rapor Kontrolü
- [ ] PROJECT_REPORT.md tamamlandı mı?
- [ ] Grup üyeleri bilgileri dolduruldu mu?
- [ ] Screenshot referansları doğru mu?
- [ ] Discussion bölümü tamamlandı mı?

### 3. Screenshot Kontrolü
- [ ] Tüm zorunlu screenshot'lar alındı mı? (8 adet)
- [ ] Screenshot'lar net ve okunabilir mi?
- [ ] Screenshot'lar doğru klasöre kopyalandı mı?
- [ ] Hive query screenshot'ları var mı? ⭐

### 4. Hive Kontrolü
- [ ] Hive tabloları oluşturuldu mu?
- [ ] Query'ler çalışıyor mu?
- [ ] Sonuçlar doğru mu?

### 5. Final Kontrol
- [ ] Zip dosyası oluşturuldu mu?
- [ ] Zip içeriği doğru mu?
- [ ] Dosya boyutu makul mü? (< 50MB önerilen)
- [ ] İsimlendirme doğru mu? (örn: `project-submission.zip`)

---

## 🚨 Kritik Eksikler (Öncelikli)

### Yüksek Öncelik:
1. ⚠️ **Hive Query Screenshot'ları** - Ödev için ZORUNLU
   - `SELECT * FROM tweets_raw_csv LIMIT 10;`
   - `SELECT * FROM tweets_stream_avro LIMIT 10;`
   - `SELECT * FROM batch_airline_sentiment;` ⭐

2. ⚠️ **PROJECT_REPORT.md'de Screenshot Referansları**
   - Screenshot'ların report'a eklenmesi
   - Doğru referansların eklenmesi

3. ⚠️ **Grup Üyeleri Bilgileri**
   - Öğrenci numaraları
   - İsimler

### Orta Öncelik:
4. Screenshot'ların `screenshots/` klasörüne organize edilmesi
5. Zip dosyasının oluşturulması
6. Final kontrolün yapılması

---

## 📝 Notlar

- Screenshot'ları aldığınızı belirttiniz, ancak Hive query screenshot'larının özellikle kontrol edilmesi gerekiyor.
- `batch_airline_sentiment` query'si ödev için EN ÖNEMLİSİ - mutlaka screenshot alınmalı.
- PROJECT_REPORT.md'de screenshot referanslarının güncellenmesi gerekiyor.

---

**Son Güncelleme:** 22 Aralık 2025

