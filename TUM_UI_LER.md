# 🌐 Tüm UI'lar ve Erişim Linkleri

Bu doküman, projede kullanılabilir tüm web arayüzlerini ve erişim bilgilerini içerir.

---

## 📊 Kullanılabilir UI'lar

### 1. ✅ Kafka UI (Ana Kafka Dashboard)
**🔗 URL:** http://localhost:8080

**📋 Açıklama:**
- Kafka cluster'ını görselleştirme ve yönetme arayüzü
- Topic'leri görüntüleme, mesajları okuma
- Consumer group'ları izleme
- Broker bilgileri
- Schema Registry entegrasyonu

**🎯 Kullanım Alanları:**
- Topic'leri görüntüleme ve yönetme
- Mesajları okuma ve analiz etme
- Consumer group'ları izleme
- Partition detaylarını görüntüleme
- Kafka metriklerini görüntüleme

**📸 Ödev İçin:**
- Topics listesi screenshot'ı
- Mesaj içerikleri screenshot'ı
- Consumer group screenshot'ı

**✅ Durum:** Çalışıyor

---

### 2. ✅ Schema Registry UI (REST API)
**🔗 URL:** http://localhost:8081

**📋 Açıklama:**
- Avro şemalarını yönetme
- REST API endpoint'leri
- Şema versiyonlarını görüntüleme

**🎯 Kullanım Alanları:**
- Avro şemalarını kaydetme ve görüntüleme
- Şema versiyonlarını yönetme
- REST API ile şema sorgulama

**📝 API Endpoint'leri:**
- `GET http://localhost:8081/subjects` - Tüm şemaları listele
- `GET http://localhost:8081/subjects/{subject}/versions` - Şema versiyonlarını listele
- `GET http://localhost:8081/schemas/ids/{id}` - ID'ye göre şema getir

**✅ Durum:** Çalışıyor (REST API, web UI yok)

**💡 Kullanım Örneği:**
```bash
# Tüm şemaları listele
curl http://localhost:8081/subjects

# Şema versiyonlarını görüntüle
curl http://localhost:8081/subjects/tweets_topic-value/versions
```

---

### 3. ✅ Hive Server Web UI
**🔗 URL:** http://localhost:10002

**📋 Açıklama:**
- Hive Server2'nin web arayüzü
- Hive konfigürasyonunu görüntüleme
- Server durumu ve bilgileri

**🎯 Kullanım Alanları:**
- Hive Server durumunu kontrol etme
- Konfigürasyon bilgilerini görüntüleme
- Server metriklerini görüntüleme

**✅ Durum:** Çalışıyor

**📸 Ödev İçin:**
- Hive Server durumu screenshot'ı (opsiyonel)

---

### 4. ⚠️ Hue (Hadoop User Experience)
**🔗 URL:** http://localhost:8888

**📋 Açıklama:**
- Hadoop ekosistemi için web tabanlı SQL arayüzü
- Hive, Spark SQL, Impala sorguları çalıştırma
- Veri görselleştirme
- Dosya tarayıcı

**🎯 Kullanım Alanları:**
- SQL sorguları çalıştırma (Hive, Spark SQL)
- Veri görselleştirme
- Tabloları görüntüleme ve yönetme
- Query geçmişi

**❌ Durum:** Şu anda çalışmıyor (container restart loop)

**💡 Alternatif:** Beeline komut satırı aracı kullanılabilir

**🔧 Sorun Giderme:**
```bash
# Container durumunu kontrol et
docker ps | grep hue

# Logları kontrol et
docker logs hue --tail 50

# Container'ı yeniden başlat
docker restart hue
```

---

### 5. ⚠️ Apache Superset
**🔗 URL:** http://localhost:8088

**📋 Açıklama:**
- Modern veri görselleştirme ve analiz platformu
- SQL sorguları çalıştırma
- Dashboard oluşturma
- Grafik ve chart'lar

**🎯 Kullanım Alanları:**
- SQL sorguları çalıştırma
- Veri görselleştirme
- Dashboard oluşturma
- Rapor oluşturma

**❌ Durum:** Şu anda çalışmıyor (config sorunu)

**🔧 Sorun Giderme:**
```bash
# Container durumunu kontrol et
docker ps | grep superset

# Logları kontrol et
docker logs superset --tail 50
```

**💡 Varsayılan Giriş Bilgileri:**
- Username: `admin`
- Password: `admin` (ilk girişte değiştirmeniz istenir)

---

## 🛠️ Komut Satırı Araçları (UI Alternatifleri)

### Beeline (Hive SQL Client)
**Kullanım:**
```bash
docker exec -it hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p ""
```

**Özellikler:**
- Hive SQL sorguları çalıştırma
- Tabloları görüntüleme
- Veri sorgulama
- ✅ Çalışıyor ve önerilen yöntem

**📸 Ödev İçin:**
- Hive query screenshot'ları için kullanılacak

---

### Kafka Console Consumer
**Kullanım:**
```bash
docker exec -it kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic tweets_topic \
  --from-beginning
```

**Özellikler:**
- Topic'lerden mesaj okuma
- Terminal'de mesaj görüntüleme

---

### Kafka Console Producer
**Kullanım:**
```bash
docker exec -it kafka kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic tweets_topic
```

**Özellikler:**
- Topic'lere mesaj gönderme
- Test mesajları gönderme

---

## 📊 Port Özeti

| Servis | Port | URL | Durum | Açıklama |
|--------|------|-----|-------|----------|
| **Kafka UI** | 8080 | http://localhost:8080 | ✅ Çalışıyor | Ana Kafka dashboard |
| **Schema Registry** | 8081 | http://localhost:8081 | ✅ Çalışıyor | REST API (web UI yok) |
| **Hive Server Web UI** | 10002 | http://localhost:10002 | ✅ Çalışıyor | Hive Server arayüzü |
| **Hue** | 8888 | http://localhost:8888 | ❌ Çalışmıyor | SQL arayüzü |
| **Superset** | 8088 | http://localhost:8088 | ❌ Çalışmıyor | Veri görselleştirme |
| **Hive Server (JDBC)** | 10000 | jdbc:hive2://localhost:10000 | ✅ Çalışıyor | Beeline bağlantısı |
| **Kafka Broker** | 9092 | localhost:9092 | ✅ Çalışıyor | Kafka broker |
| **PostgreSQL** | 5432 | localhost:5432 | ✅ Çalışıyor | Veritabanı |

---

## 🎯 Ödev İçin Önerilen UI'lar

### Zorunlu:
1. ✅ **Kafka UI** (http://localhost:8080)
   - Topics listesi
   - Mesaj içerikleri
   - Consumer groups

2. ✅ **Beeline** (Komut satırı)
   - Hive SQL sorguları

### Opsiyonel:
3. ✅ **Hive Server Web UI** (http://localhost:10002)
   - Server durumu

4. ✅ **Schema Registry** (http://localhost:8081)
   - REST API ile şema sorgulama

---

## 🚀 Hızlı Erişim Komutları

### Tüm UI'ları Tarayıcıda Aç (Mac):
```bash
# Kafka UI
open http://localhost:8080

# Hive Server Web UI
open http://localhost:10002

# Schema Registry API
open http://localhost:8081
```

### Durum Kontrolü:
```bash
# Tüm container'ları listele
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Belirli servisleri kontrol et
docker ps | grep -E "kafka-ui|hive-server|hue|superset"
```

---

## 📝 UI Kullanım Senaryoları

### Senaryo 1: Kafka Topic'lerini İnceleme
1. Kafka UI'ı aç: http://localhost:8080
2. Sol menüden "Topics" sekmesine git
3. `tweets_topic` veya `realtime_alerts`'e tıkla
4. "Messages" sekmesinden mesajları görüntüle

### Senaryo 2: Hive SQL Sorguları Çalıştırma
1. Terminal'de Beeline'a bağlan:
   ```bash
   docker exec -it hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p ""
   ```
2. SQL sorgularını çalıştır:
   ```sql
   SHOW TABLES;
   SELECT * FROM batch_airline_sentiment;
   ```

### Senaryo 3: Schema Registry'den Şema Görüntüleme
```bash
# Tüm şemaları listele
curl http://localhost:8081/subjects

# Belirli bir şema versiyonunu görüntüle
curl http://localhost:8081/subjects/tweets_topic-value/versions/1
```

---

## 🔧 Sorun Giderme

### UI Açılmıyor:
1. Container'ın çalıştığını kontrol et:
   ```bash
   docker ps | grep <container-name>
   ```
2. Port'un kullanıldığını kontrol et:
   ```bash
   lsof -i :8080  # Kafka UI için
   ```
3. Container'ı yeniden başlat:
   ```bash
   docker restart <container-name>
   ```

### Hue/Superset Çalışmıyor:
- Beeline kullanarak SQL sorgularını çalıştırabilirsiniz
- Kafka UI'dan Kafka işlemlerini yapabilirsiniz
- Hive Server Web UI'dan Hive durumunu kontrol edebilirsiniz

---

## ✅ Özet

**Çalışan UI'lar:**
- ✅ Kafka UI (http://localhost:8080) - Ana dashboard
- ✅ Schema Registry (http://localhost:8081) - REST API
- ✅ Hive Server Web UI (http://localhost:10002) - Hive durumu
- ✅ Beeline (Komut satırı) - SQL sorguları için en iyi seçenek

**Çalışmayan UI'lar:**
- ❌ Hue (http://localhost:8888) - Sorunlu
- ❌ Superset (http://localhost:8088) - Config sorunu

**Öneri:** Ödev için Kafka UI ve Beeline yeterli. Diğer UI'lar opsiyonel.

---

**Son Güncelleme:** 22 Aralık 2025
**Proje:** Twitter Airline Sentiment Analysis

