# 📸 Ödev İçin Screenshot Rehberi

Bu doküman, ödev için alınması gereken tüm screenshot'ları, linkleri ve adım adım talimatları içerir.

---

## 🎯 Ödev Gereksinimleri (homework.md'den)

Ödev şunları istiyor:
1. ✅ Stream processing job çalışırken console output
2. ✅ Hive tablolarından SELECT sorguları:
   - `SELECT * FROM tweets_raw_csv LIMIT 10;`
   - `SELECT * FROM tweets_stream_avro LIMIT 10;`
   - `SELECT * FROM batch_airline_sentiment;`

---

## 📋 Screenshot Listesi ve Linkler

### BÖLÜM 1: Kafka UI Screenshots

#### 1. Kafka UI Ana Sayfa (Cluster Overview)
**🔗 Link:** http://localhost:8080

**📸 Ne Alınacak:**
- Ana sayfada cluster durumu
- Topic sayısı (2 topic görünmeli: `tweets_topic`, `realtime_alerts`)
- Broker sayısı (1 broker)
- Consumer group sayısı

**📁 Dosya Adı:** `01_kafka_cluster_overview.png`

**📍 Adımlar:**
1. Tarayıcıda http://localhost:8080 aç
2. Ana sayfayı screenshot al
3. Topic sayılarının görünür olduğundan emin ol

---

#### 2. Topics Listesi ✅
**🔗 Link:** http://localhost:8080/topics

**📸 Ne Alınacak:**
- `tweets_topic` (3 partitions, mesaj sayısı görünür)
- `realtime_alerts` (3 partitions, mesaj sayısı görünür)
- Her topic'in partition sayısı ve toplam mesaj sayısı

**📁 Dosya Adı:** `topics.jpeg` ✅ **ALINDI**

**📍 Adımlar:**
1. Sol menüden "Topics" sekmesine tıkla
2. Her iki topic'in görünür olduğundan emin ol
3. Screenshot al

**📸 Mevcut Screenshot:** `screenshots/topics.jpeg`

---

#### 3. tweets_topic - Topic Detayları ✅
**🔗 Link:** http://localhost:8080/topics/tweets_topic

**📸 Ne Alınacak:**
- Topic adı: `tweets_topic`
- Partition sayısı: 3
- Mesaj sayısı ve boyutu
- Topic konfigürasyonu
- Partition detayları

**📁 Dosya Adı:** `tweets_topic.jpeg` ✅ **ALINDI**

**📍 Adımlar:**
1. Topics listesinden `tweets_topic`'e tıkla
2. Topic detay sayfasını aç
3. Partition ve mesaj bilgilerinin görünür olduğundan emin ol
4. Screenshot al

**📸 Mevcut Screenshot:** `screenshots/tweets_topic.jpeg`

---

#### 4. realtime_alerts - Topic Detayları ✅
**🔗 Link:** http://localhost:8080/topics/realtime_alerts

**📸 Ne Alınacak:**
- Topic adı: `realtime_alerts`
- Partition sayısı: 3
- Alert mesaj sayısı
- Stream processing sonuçları
- Topic konfigürasyonu

**📁 Dosya Adı:** `realtime_alerts_topic.jpeg` ✅ **ALINDI**

**📍 Adımlar:**
1. Topics listesinden `realtime_alerts`'e tıkla
2. Topic detay sayfasını aç
3. Alert mesaj sayısının görünür olduğundan emin ol
4. Screenshot al

**📸 Mevcut Screenshot:** `screenshots/realtime_alerts_topic.jpeg`

---

#### 5. Consumer Groups - sentiment-alert-app ✅
**🔗 Link:** http://localhost:8080/consumer-groups/sentiment-alert-app

**📸 Ne Alınacak:**
- `sentiment-alert-app` consumer group'u
- State: ACTIVE görünür olmalı
- Lag bilgisi görünür olmalı
- Partition assignment'ları
- Topic'ler: `tweets_topic` ve `realtime_alerts`

**📁 Dosya Adı:** `sentiment-alert-app-consumer.jpeg` ✅ **ALINDI**

**📍 Adımlar:**
1. Sol menüden "Consumer Groups" sekmesine tıkla
2. `sentiment-alert-app`'e tıkla
3. Consumer group detaylarının görünür olduğundan emin ol
4. Screenshot al

**📸 Mevcut Screenshot:** `screenshots/sentiment-alert-app-consumer.jpeg`

---

### BÖLÜM 2: Stream Processing Console Output

#### 6. Kafka Streams Console Output
**🔗 Link:** Terminal (Kafka Streams uygulamasının çalıştığı)

**📸 Ne Alınacak:**
- Uygulama başlangıç mesajları
- Negatif sentiment uyarıları (en az 5-10 örnek)
- Örnek çıktı:
  ```
  ================================================================================
  🚨 NEGATIVE SENTIMENT DETECTED!
  ================================================================================
  Airline: United
  Tweet ID: 570306133677760513
  Text: @united you lost my luggage again!
  ================================================================================
  ```

**📁 Dosya Adı:** `06_kafka_streams_console.png`

**📍 Adımlar:**
1. Kafka Streams uygulamasının çalıştığı terminali aç
2. En az 5-10 uyarı mesajı görünür olacak şekilde scroll yap
3. Terminal penceresini screenshot al
4. Uyarı mesajlarının tamamı görünür olmalı

**💡 İpucu:** Terminal font boyutunu küçültüp daha fazla satır görünür hale getirebilirsiniz.

---

### BÖLÜM 3: Spark Batch Job Console Output

#### 7. Spark Batch Job Console Output
**🔗 Link:** Terminal (Spark job'ının çalıştığı)

**📸 Ne Alınacak:**
- Spark session başlatma mesajları
- Veri yükleme mesajları
- Analiz sonuçları tablosu:
  ```
  +-------+------------+---------------+---------------+--------------+--------------+
  |airline|total_tweets|positive_count|negative_count|neutral_count|negative_ratio|
  +-------+------------+---------------+---------------+--------------+--------------+
  | United|        3823|            ...|            ...|           ...|           ...|
  |American|        2759|            ...|            ...|           ...|           ...|
  ...
  ```
- Parquet kaydetme mesajları
- Job completion mesajı

**📁 Dosya Adı:** `07_spark_batch_console.png`

**📍 Adımlar:**
1. Spark job'ının çalıştığı terminali aç
2. Sonuçlar tablosunun tamamı görünür olacak şekilde scroll yap
3. Terminal penceresini screenshot al
4. Tüm havayolları ve sonuçları görünür olmalı

---

### BÖLÜM 4: Hive SQL Query Screenshots (ZORUNLU)

#### 8. Hive Query 1: tweets_raw_csv
**🔗 Link:** Terminal (Beeline ile)

**📸 Ne Alınacak:**
- SQL sorgusu görünür:
  ```sql
  SELECT * FROM tweets_raw_csv LIMIT 10;
  ```
- Sonuçlar tablosu (en az 5-10 satır):
  ```
  +------------------+------------------+--------------------------+...
  | tweet_id         | airline_sentiment| airline_sentiment_confidence|...
  +------------------+------------------+--------------------------+...
  | 570306133677760513| negative        | 1.0                      |...
  | 570306130462408193| neutral         | 1.0                      |...
  ...
  ```

**📁 Dosya Adı:** `08_hive_tweets_raw_csv.png`

**📍 Adımlar:**
1. Terminal'de şu komutu çalıştır:
   ```bash
   docker exec -it hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p ""
   ```
2. Beeline'a bağlandıktan sonra şu sorguyu çalıştır:
   ```sql
   SELECT * FROM tweets_raw_csv LIMIT 10;
   ```
3. Sonuçlar göründüğünde terminal penceresini screenshot al
4. SQL sorgusu ve sonuçların tamamı görünür olmalı

**⚠️ Not:** Eğer tablo boşsa, önce Spark batch job'ını çalıştırın veya CSV dosyasını Hive'a yükleyin.

---

#### 9. Hive Query 2: tweets_stream_avro
**🔗 Link:** Terminal (Beeline ile)

**📸 Ne Alınacak:**
- SQL sorgusu görünür:
  ```sql
  SELECT * FROM tweets_stream_avro LIMIT 10;
  ```
- Sonuçlar tablosu (eğer veri varsa)

**📁 Dosya Adı:** `09_hive_tweets_stream_avro.png`

**📍 Adımlar:**
1. Beeline'da şu sorguyu çalıştır:
   ```sql
   SELECT * FROM tweets_stream_avro LIMIT 10;
   ```
2. Sonuçlar göründüğünde terminal penceresini screenshot al

**⚠️ Not:** Bu tablo stream verilerini içerir. Eğer boşsa, Kafka Streams uygulamasının veriyi Hive'a yazdığından emin olun.

---

#### 10. Hive Query 3: batch_airline_sentiment (ZORUNLU)
**🔗 Link:** Terminal (Beeline ile)

**📸 Ne Alınacak:**
- SQL sorgusu görünür:
  ```sql
  SELECT * FROM batch_airline_sentiment;
  ```
- Sonuçlar tablosu (TÜM havayolları görünür olmalı):
  ```
  +-------+------------+---------------+---------------+--------------+--------------+
  |airline|total_tweets|positive_count|negative_count|neutral_count|negative_ratio|
  +-------+------------+---------------+---------------+--------------+--------------+
  | United|        3823|            ...|            ...|           ...|           ...|
  |American|        2759|            ...|            ...|           ...|           ...|
  |Southwest|       2420|            ...|            ...|           ...|           ...|
  |Delta  |        2222|            ...|            ...|           ...|           ...|
  |Virgin America|  504|            ...|            ...|           ...|           ...|
  |US Airways|     2773|            ...|            ...|           ...|           ...|
  +-------+------------+---------------+---------------+--------------+--------------+
  ```

**📁 Dosya Adı:** `10_hive_batch_airline_sentiment.png`

**📍 Adımlar:**
1. Beeline'da şu sorguyu çalıştır:
   ```sql
   SELECT * FROM batch_airline_sentiment;
   ```
2. Tüm havayolları görünür olacak şekilde scroll yap
3. Terminal penceresini screenshot al
4. Tüm satırlar görünür olmalı

**⚠️ ÖNEMLİ:** Bu sorgu ödev için ZORUNLU! Spark batch job çalıştıktan sonra bu tabloda veri olmalı.

---

### BÖLÜM 5: Hive Web UI (Opsiyonel ama Önerilen)

#### 11. Hive Server Web UI
**🔗 Link:** http://localhost:10002

**📸 Ne Alınacak:**
- Hive Server ana sayfası
- Hive konfigürasyon bilgileri
- Server durumu

**📁 Dosya Adı:** `11_hive_server_web_ui.png`

**📍 Adımlar:**
1. Tarayıcıda http://localhost:10002 aç
2. Ana sayfayı screenshot al

---

### BÖLÜM 6: Docker Containers (Sistem Durumu)

#### 12. Kafka Brokers ✅
**🔗 Link:** http://localhost:8080/brokers

**📸 Ne Alınacak:**
- Broker ID: 1
- Broker durumu: UP
- Disk ve network metrikleri
- Cluster sağlık durumu
- Broker konfigürasyonu

**📁 Dosya Adı:** `brokers.jpeg` ✅ **ALINDI**

**📍 Adımlar:**
1. Kafka UI'da sol menüden "Brokers" sekmesine tıkla
2. Broker detaylarının görünür olduğundan emin ol
3. Screenshot al

**📸 Mevcut Screenshot:** `screenshots/brokers.jpeg`

---

#### 13. Hive Server Web UI ✅
**🔗 Link:** http://localhost:10002

**📸 Ne Alınacak:**
- HiveServer2 durumu
- Konfigürasyon bilgileri
- Server metrikleri
- Hive versiyonu ve build bilgileri

**📁 Dosya Adı:** `hive-ui.jpeg` ✅ **ALINDI**

**📍 Adımlar:**
1. Tarayıcıda http://localhost:10002 aç
2. Hive Server Web UI ana sayfasını screenshot al

**📸 Mevcut Screenshot:** `screenshots/hive-ui.jpeg`

---

## ✅ Ödev İçin Minimum Gereksinimler

### ZORUNLU Screenshot'lar:
1. ✅ **Kafka Topics Listesi** (tweets_topic ve realtime_alerts görünür)
2. ✅ **tweets_topic Messages** (en az 5 mesaj örneği)
3. ✅ **realtime_alerts Messages** (en az 3 alert örneği)
4. ✅ **Kafka Streams Console Output** (uyarı örnekleri)
5. ✅ **Spark Batch Job Console Output** (sonuçlar tablosu)
6. ✅ **Hive Query: tweets_raw_csv** (`SELECT * FROM tweets_raw_csv LIMIT 10;`)
7. ✅ **Hive Query: tweets_stream_avro** (`SELECT * FROM tweets_stream_avro LIMIT 10;`)
8. ✅ **Hive Query: batch_airline_sentiment** (`SELECT * FROM batch_airline_sentiment;`) ⭐ EN ÖNEMLİSİ

### Önerilen Ek Screenshot'lar:
- Consumer Groups
- Docker Containers
- Hive Server Web UI

---

## 🚀 Screenshot Alma Öncesi Kontrol Listesi

Screenshot almadan önce şunları kontrol edin:

- [ ] Kafka UI çalışıyor mu? (http://localhost:8080)
- [ ] Kafka Streams uygulaması çalışıyor mu?
- [ ] Producer çalıştı mı ve veri gönderdi mi?
- [ ] Topic'lerde mesaj var mı?
- [ ] Spark batch job çalıştı mı?
- [ ] Hive tabloları oluşturuldu mu?
- [ ] Hive tablolarında veri var mı?
- [ ] Docker container'lar çalışıyor mu?

---

## 📝 Hive Query'leri Çalıştırma (Adım Adım)

### 1. Beeline'a Bağlan
```bash
docker exec -it hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p ""
```

### 2. Tabloları Kontrol Et
```sql
SHOW TABLES;
```
Çıktıda şunlar görünmeli:
- `batch_airline_sentiment`
- `tweets_raw_csv`
- `tweets_stream_avro`

### 3. Zorunlu Query'leri Çalıştır

**Query 1:**
```sql
SELECT * FROM tweets_raw_csv LIMIT 10;
```

**Query 2:**
```sql
SELECT * FROM tweets_stream_avro LIMIT 10;
```

**Query 3:**
```sql
SELECT * FROM batch_airline_sentiment;
```

### 4. Beeline'dan Çık
```sql
!quit
```

---

## 📁 Dosya Organizasyonu

Screenshot'lar şu şekilde organize edilmiştir:

```
screenshots/
├── topics.jpeg                          ✅ ALINDI
├── tweets_topic.jpeg                    ✅ ALINDI
├── realtime_alerts_topic.jpeg           ✅ ALINDI
├── brokers.jpeg                         ✅ ALINDI
├── sentiment-alert-app-consumer.jpeg    ✅ ALINDI
├── hive-ui.jpeg                         ✅ ALINDI
├── [GEREKLİ] kafka_streams_console.png ⚠️ EKSİK
├── [GEREKLİ] spark_batch_console.png   ⚠️ EKSİK
├── [ZORUNLU] hive_tweets_raw_csv.png   ⚠️ EKSİK
├── [ZORUNLU] hive_tweets_stream_avro.png ⚠️ EKSİK
└── [ZORUNLU] hive_batch_airline_sentiment.png ⚠️ EKSİK (EN ÖNEMLİSİ)
```

**✅ Alınan Screenshot'lar:**
- Kafka Topics Listesi
- Tweets Topic Detayları
- Realtime Alerts Topic Detayları
- Kafka Brokers
- Consumer Group (sentiment-alert-app)
- Hive Server Web UI

**⚠️ Eksik Screenshot'lar:**
- Kafka Streams Console Output
- Spark Batch Job Console Output
- Hive Query: tweets_raw_csv (ZORUNLU)
- Hive Query: tweets_stream_avro (ZORUNLU)
- Hive Query: batch_airline_sentiment (ZORUNLU - EN ÖNEMLİSİ)

---

## 💡 Screenshot Alma İpuçları

### Genel Kurallar:
1. **Tam Ekran:** Mümkünse tam ekran screenshot alın
2. **Net Görünürlük:** Tüm metinler okunabilir olmalı
3. **Önemli Bilgiler:** Topic adları, mesaj sayıları, SQL sorguları görünür olmalı
4. **Zaman Damgası:** Sistemin çalıştığını gösteren zaman damgaları görünür olmalı

### Terminal Screenshot İpuçları:
1. **Font Boyutu:** Terminal font boyutunu okunabilir yapın (12-14pt)
2. **Renkler:** Renkli çıktıları koruyun
3. **Scroll:** Uzun çıktılar için birden fazla screenshot alın
4. **Tam Görünürlük:** SQL sorgusu ve sonuçların tamamı görünür olmalı

### Web UI Screenshot İpuçları:
1. **Zoom:** Tarayıcı zoom'unu %100'de tutun
2. **Tablo Görünümü:** Tabloların tamamı görünür olmalı
3. **Scroll:** Gerekirse birden fazla screenshot alın

---

## 🔧 Sorun Giderme

### Hive Tabloları Boş Görünüyor:
1. Spark batch job'ını çalıştırın:
   ```bash
   ./scripts/run_spark_job.sh
   ```
2. Tabloları tekrar sorgulayın

### Beeline Bağlanamıyor:
1. Hive Server'ın çalıştığını kontrol edin:
   ```bash
   docker ps | grep hive-server
   ```
2. Container'ı yeniden başlatın:
   ```bash
   docker restart hive-server
   ```

### Kafka UI'da Mesaj Görünmüyor:
1. Producer'ı çalıştırın:
   ```bash
   ./scripts/run_producer.sh
   ```
2. Birkaç saniye bekleyin
3. Kafka UI'ı yenileyin

---

## 📊 Ödev Raporunda Kullanım

Ödev raporunuzda screenshot'ları şu şekilde referans edin:

> **Figure 1:** Kafka Topics Listesi - tweets_topic ve realtime_alerts topic'lerinin oluşturulduğunu ve mesaj içerdiğini gösterir.

> **Figure 2:** Kafka Streams Console Output - Negatif sentiment tespit edildiğinde gerçek zamanlı uyarıların üretildiğini gösterir.

> **Figure 3:** Spark Batch Job Sonuçları - Tüm havayolları için sentiment analizi sonuçlarını gösterir.

> **Figure 4:** Hive Query Sonuçları - batch_airline_sentiment tablosundan tüm havayolları için toplam tweet sayıları ve negative ratio değerlerini gösterir.

---

## ✅ Final Kontrol

Ödev tesliminden önce kontrol edin:

- [ ] Tüm zorunlu screenshot'lar alındı mı? (8 adet)
- [ ] Hive query'leri çalıştırıldı mı ve sonuçlar görünür mü?
- [ ] Screenshot'larda önemli bilgiler (topic adları, mesaj sayıları, SQL sorguları) görünür mü?
- [ ] Dosya adları doğru mu?
- [ ] Screenshot'lar net ve okunabilir mi?

---

**Hazırlayan:** Meriç Özkayağan
**Tarih:** 22 Aralık 2025
**Proje:** Twitter Airline Sentiment Analysis - Lambda Architecture

