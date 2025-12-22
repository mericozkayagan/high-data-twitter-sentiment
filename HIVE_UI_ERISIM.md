# Hive SQL UI Erişim Rehberi

## 🎯 Kullanılabilir UI Seçenekleri

### 1. Hive Server Web UI (Çalışıyor ✅)
**URL:** http://localhost:10002

Hive Server'ın kendi web arayüzü. Buradan:
- Hive konfigürasyonunu görüntüleyebilirsiniz
- Temel bilgileri görebilirsiniz
- SQL sorguları için Beeline kullanmanız gerekir

### 2. Beeline (Komut Satırı - En Güvenilir)
**Kullanım:**
```bash
docker exec -it hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p ""
```

**Örnek Sorgular:**
```sql
-- Tüm tabloları listele
SHOW TABLES;

-- Tablo yapısını görüntüle
DESCRIBE batch_airline_sentiment;

-- Veri sorgula
SELECT * FROM batch_airline_sentiment LIMIT 10;

-- Tüm tabloları ve kayıt sayılarını göster
SELECT 'batch_airline_sentiment' as table_name, COUNT(*) as row_count
FROM batch_airline_sentiment
UNION ALL
SELECT 'tweets_raw_csv' as table_name, COUNT(*) as row_count
FROM tweets_raw_csv
UNION ALL
SELECT 'tweets_stream_avro' as table_name, COUNT(*) as row_count
FROM tweets_stream_avro;
```

### 3. Apache Superset (Kurulum Aşamasında)
**URL:** http://localhost:8088

Superset başlatıldı ancak Hive bağlantısı için yapılandırma gerekiyor.

**Varsayılan Kullanıcı:**
- Username: `admin`
- Password: `admin` (ilk girişte değiştirmeniz istenir)

**Hive Bağlantısı Eklemek İçin:**
1. Superset'e giriş yapın
2. Settings > Database Connections
3. Yeni bağlantı ekleyin:
   - **Database Type:** Apache Hive
   - **SQLAlchemy URI:** `hive://hive-server:10000/default`
   - **Display Name:** Hive Twitter Sentiment

## 📊 Oluşturulan Tablolar

1. **batch_airline_sentiment**
   - Spark batch job sonuçları
   - Format: Parquet
   - Kolonlar: airline, total_tweets, positive_count, negative_count, neutral_count, negative_ratio

2. **tweets_raw_csv**
   - Ham CSV verileri
   - Format: TextFile (CSV)
   - Tüm tweet kolonları

3. **tweets_stream_avro**
   - Stream verileri
   - Format: Avro
   - Partitioned by: dt (date)

## 🔍 Hızlı Test

Beeline ile hızlı test:
```bash
docker exec hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p "" -e "SHOW TABLES;"
```

## 📝 Notlar

- Spark batch job çalıştıktan sonra `batch_airline_sentiment` tablosunda veriler görünecektir
- Hive tabloları external table olarak oluşturulmuştur, veriler dosya sisteminde saklanır
- Hue container'ında sorun var, alternatif olarak Beeline veya Superset kullanabilirsiniz

