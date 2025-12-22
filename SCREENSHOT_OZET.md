# 📸 Screenshot Özeti ve Durum

Bu doküman, projede alınan screenshot'ların durumunu ve kullanım yerlerini gösterir.

---

## ✅ Alınan Screenshot'lar

### 1. Kafka Topics Listesi
**📁 Dosya:** `screenshots/topics.jpeg` (87K)
**📍 Kullanım:**
- PROJECT_REPORT.md - Bölüm 5.1
- PROJECT_REPORT_EN.md - Bölüm 5.1
- PROJE_DOKUMANTASYONU.md - Bölüm 2

**Görünen Bilgiler:**
- `tweets_topic` (3 partitions)
- `realtime_alerts` (3 partitions)
- Mesaj sayıları
- Partition bilgileri

---

### 2. Tweets Topic Detayları
**📁 Dosya:** `screenshots/tweets_topic.jpeg` (77K)
**📍 Kullanım:**
- PROJECT_REPORT.md - Bölüm 5.2
- PROJECT_REPORT_EN.md - Bölüm 5.2
- PROJE_DOKUMANTASYONU.md - Bölüm 3

**Görünen Bilgiler:**
- Topic adı: `tweets_topic`
- Partition sayısı: 3
- Mesaj sayısı ve boyutu
- Topic konfigürasyonu

---

### 3. Realtime Alerts Topic Detayları
**📁 Dosya:** `screenshots/realtime_alerts_topic.jpeg` (73K)
**📍 Kullanım:**
- PROJECT_REPORT.md - Bölüm 5.3
- PROJECT_REPORT_EN.md - Bölüm 5.3
- PROJE_DOKUMANTASYONU.md - Bölüm 5

**Görünen Bilgiler:**
- Topic adı: `realtime_alerts`
- Partition sayısı: 3
- Alert mesaj sayısı
- Stream processing sonuçları

---

### 4. Kafka Brokers
**📁 Dosya:** `screenshots/brokers.jpeg` (63K)
**📍 Kullanım:**
- PROJECT_REPORT.md - Bölüm 5.4
- PROJECT_REPORT_EN.md - Bölüm 5.4
- PROJE_DOKUMANTASYONU.md - Bölüm 9

**Görünen Bilgiler:**
- Broker ID: 1
- Broker durumu: UP
- Disk ve network metrikleri
- Cluster sağlık durumu

---

### 5. Consumer Group - sentiment-alert-app
**📁 Dosya:** `screenshots/sentiment-alert-app-consumer.jpeg` (67K)
**📍 Kullanım:**
- PROJECT_REPORT.md - Bölüm 5.5
- PROJECT_REPORT_EN.md - Bölüm 5.5
- PROJE_DOKUMANTASYONU.md - Bölüm 8

**Görünen Bilgiler:**
- Consumer group adı: `sentiment-alert-app`
- State: ACTIVE
- Partition assignment'ları
- Offset ve lag bilgileri
- Topic'ler: `tweets_topic` ve `realtime_alerts`

---

### 6. Hive Server Web UI
**📁 Dosya:** `screenshots/hive-ui.jpeg` (219K)
**📍 Kullanım:**
- PROJECT_REPORT.md - Bölüm 5.6
- PROJECT_REPORT_EN.md - Bölüm 5.6
- PROJE_DOKUMANTASYONU.md - Bölüm 10

**Görünen Bilgiler:**
- HiveServer2 durumu
- Konfigürasyon bilgileri
- Server metrikleri
- Hive versiyonu

---

## ⚠️ Eksik Screenshot'lar (Ödev İçin Zorunlu)

### 7. Kafka Streams Console Output
**📁 Dosya:** `screenshots/kafka_streams_console.png` (Henüz alınmadı)
**📍 Nerede Alınır:** Kafka Streams uygulamasının çalıştığı terminal
**📸 Ne Alınacak:**
- Uygulama başlangıç mesajları
- Negatif sentiment uyarıları (en az 5-10 örnek)
- Alert formatı

**Örnek:**
```
================================================================================
🚨 NEGATIVE SENTIMENT DETECTED!
================================================================================
Airline: United
Tweet ID: 570306133677760513
Text: @united you lost my luggage again!
================================================================================
```

---

### 8. Spark Batch Job Console Output
**📁 Dosya:** `screenshots/spark_batch_console.png` (Henüz alınmadı)
**📍 Nerede Alınır:** Spark job'ının çalıştığı terminal
**📸 Ne Alınacak:**
- Spark session başlatma
- Veri yükleme mesajları
- Analiz sonuçları tablosu (tüm havayolları)
- Parquet kaydetme mesajları

---

### 9. Hive Query: tweets_raw_csv ⚠️ ZORUNLU
**📁 Dosya:** `screenshots/hive_tweets_raw_csv.png` (Henüz alınmadı)
**📍 Nerede Alınır:** Beeline terminal
**📸 Ne Alınacak:**
- SQL sorgusu: `SELECT * FROM tweets_raw_csv LIMIT 10;`
- Sonuçlar tablosu (en az 5-10 satır)
- Kolonlar görünür olmalı

---

### 10. Hive Query: tweets_stream_avro ⚠️ ZORUNLU
**📁 Dosya:** `screenshots/hive_tweets_stream_avro.png` (Henüz alınmadı)
**📍 Nerede Alınır:** Beeline terminal
**📸 Ne Alınacak:**
- SQL sorgusu: `SELECT * FROM tweets_stream_avro LIMIT 10;`
- Sonuçlar tablosu (eğer veri varsa)

---

### 11. Hive Query: batch_airline_sentiment ⚠️ ZORUNLU - EN ÖNEMLİSİ
**📁 Dosya:** `screenshots/hive_batch_airline_sentiment.png` (Henüz alınmadı)
**📍 Nerede Alınır:** Beeline terminal
**📸 Ne Alınacak:**
- SQL sorgusu: `SELECT * FROM batch_airline_sentiment;`
- Sonuçlar tablosu (TÜM havayolları görünür olmalı):
  ```
  +-------+------------+---------------+---------------+--------------+--------------+
  |airline|total_tweets|positive_count|negative_count|neutral_count|negative_ratio|
  +-------+------------+---------------+---------------+--------------+--------------+
  | United|        3822|           492|          2633|           697|        0.6889|
  |US Airways|     2913|           269|          2263|           381|        0.7769|
  |American|      2759|           336|          1960|           463|        0.7104|
  |Southwest|     2420|           570|          1186|           664|        0.4901|
  |Delta  |       2222|           544|           955|           723|        0.4298|
  |Virgin America| 504|           152|           181|           171|        0.3591|
  +-------+------------+---------------+---------------+--------------+--------------+
  ```

**⚠️ ÖNEMLİ:** Bu screenshot ödev için EN ÖNEMLİSİ! Mutlaka alınmalı.

---

## 📊 Screenshot Durum Özeti

| Screenshot | Durum | Dosya | Boyut |
|------------|-------|-------|-------|
| Topics Listesi | ✅ Alındı | `topics.jpeg` | 87K |
| Tweets Topic | ✅ Alındı | `tweets_topic.jpeg` | 77K |
| Realtime Alerts Topic | ✅ Alındı | `realtime_alerts_topic.jpeg` | 73K |
| Brokers | ✅ Alındı | `brokers.jpeg` | 63K |
| Consumer Group | ✅ Alındı | `sentiment-alert-app-consumer.jpeg` | 67K |
| Hive Server Web UI | ✅ Alındı | `hive-ui.jpeg` | 219K |
| Kafka Streams Console | ⚠️ Eksik | - | - |
| Spark Batch Console | ⚠️ Eksik | - | - |
| Hive Query: tweets_raw_csv | ⚠️ Eksik (ZORUNLU) | - | - |
| Hive Query: tweets_stream_avro | ⚠️ Eksik (ZORUNLU) | - | - |
| Hive Query: batch_airline_sentiment | ⚠️ Eksik (ZORUNLU) | - | - |

**Toplam:** 6/11 screenshot alındı (%55)

---

## 📝 Raporlarda Kullanım

### PROJECT_REPORT.md
- ✅ Bölüm 5.1: Topics Listesi
- ✅ Bölüm 5.2: Tweets Topic Detayları
- ✅ Bölüm 5.3: Realtime Alerts Topic
- ✅ Bölüm 5.4: Kafka Brokers
- ✅ Bölüm 5.5: Consumer Groups
- ✅ Bölüm 5.6: Hive Server Web UI

### PROJECT_REPORT_EN.md
- ✅ Section 5.1: Topics List
- ✅ Section 5.2: Tweets Topic Details
- ✅ Section 5.3: Realtime Alerts Topic
- ✅ Section 5.4: Kafka Brokers
- ✅ Section 5.5: Consumer Groups
- ✅ Section 5.6: Hive Server Web UI

### PROJE_DOKUMANTASYONU.md
- ✅ Bölüm 2: Topics Listesi
- ✅ Bölüm 3: tweets_topic Detayları
- ✅ Bölüm 5: realtime_alerts Topic
- ✅ Bölüm 8: Consumer Group Detayları
- ✅ Bölüm 9: Broker Metrikleri
- ✅ Bölüm 10: Hive Server Web UI

---

## 🎯 Sonraki Adımlar

1. ⚠️ **Kafka Streams Console Output** screenshot'ı alınmalı
2. ⚠️ **Spark Batch Job Console Output** screenshot'ı alınmalı
3. ⚠️ **Hive Query Screenshot'ları** alınmalı (3 adet - ZORUNLU)
   - Özellikle `batch_airline_sentiment` query'si EN ÖNEMLİSİ

---

**Son Güncelleme:** 22 Aralık 2025

