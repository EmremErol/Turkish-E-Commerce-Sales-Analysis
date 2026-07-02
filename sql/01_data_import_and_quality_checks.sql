USE ETicaretDB;
GO

/* 
   01Aktarýlan tablolarý kontrol etme 

   Bu sorgu, veritabanýna aktarýlan tablolarýn listesini gösterir.
   Import iþlemi sonrasý tablolarýn SQL Server'da oluþup oluþmadýðýný
   kontrol etmek için kullanýlmýþtýr.
*/
SELECT
    name AS TableName,
    create_date AS CreatedDate,
    modify_date AS ModifiedDate
FROM sys.tables
ORDER BY name;

/* 
   Satýr sayýsý kontrolü

   Bu sorgu, her tablodaki toplam satýr sayýsýný gösterir.
   CSV dosyalarýndan SQL Server'a veri aktarýmý yapýldýktan sonra
   verilerin eksik gelip gelmediðini kontrol etmek için kullanýlmýþtýr.
 */
SELECT 'Iadeler' AS Tablo, COUNT(*) AS SatirSayisi FROM Iadeler
UNION ALL
SELECT 'Kargo', COUNT(*) FROM Kargo
UNION ALL
SELECT 'Kategoriler', COUNT(*) FROM Kategoriler
UNION ALL
SELECT 'Musteriler', COUNT(*) FROM Musteriler
UNION ALL
SELECT 'Sehirler', COUNT(*) FROM Sehirler
UNION ALL
SELECT 'Siparisler', COUNT(*) FROM Siparisler
UNION ALL
SELECT 'SiparisDetaylari', COUNT(*) FROM SiparislerDetaylari
UNION ALL
SELECT 'Takvim', COUNT(*) FROM Takvim
UNION ALL
SELECT 'Urunler', COUNT(*) FROM Urunler;
GO

/* 
   Kolon ve veri tipi kontrolü 

   Bu sorgu, import edilen tablolarýn kolon adlarýný, veri tiplerini
   ve NULL deðer kabul edip etmediðini gösterir.

   Import sýrasýnda bazý para ve tarih alanlarý bilinçli olarak
   NVARCHAR tipinde alýnmýþtýr. Çünkü Türkçe para formatlarý
   doðrudan DECIMAL veri tipine çevrilememiþtir.
*/

SELECT
    TABLE_NAME AS TabloÝsmi,
    COLUMN_NAME AS Kolon,
    DATA_TYPE AS VeriTipi,
    CHARACTER_MAXIMUM_LENGTH AS MaxLength,
    IS_NULLABLE AS BosDegerAlabilir
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'Iadeler',
    'Kargo',
    'Kategoriler',
    'Musteriler',
    'Sehirler',
    'Siparisler',
    'SiparisDetaylari',
    'Takvim',
    'Urunler'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;

/* 
   Örnek veri konteolleri 

   Bu sorgular, her tablodan ilk 10 satýrý gösterir.
 */
SELECT TOP 10 *
FROM Iadeler;

SELECT TOP 10 *
FROM Kargo;


SELECT TOP 10 *
FROM Kategoriler;


SELECT TOP 10 *
FROM Musteriler;


SELECT TOP 10 *
FROM Sehirler;


SELECT TOP 10 *
FROM Siparisler;


SELECT TOP 10 *
FROM SiparislerDetaylari;


SELECT TOP 10 *
FROM Takvim;


SELECT TOP 10 *
FROM Urunler;

/* 
   Tekrarlý ID kontrolleri

   Bu sorgu, Primary Key olarak kullanýlacak ID kolonlarýnda
   tekrarlý deðer olup olmadýðýný kontrol eder.

   Sonuç boþ gelirse:
   - Tekrarlý ID yoktur.
   - Primary Key oluþturmak için veri uygundur.
*/
SELECT 'Iadeler' AS Tablo, CAST(IadeID AS NVARCHAR(50)) AS IDDegeri, COUNT(*) AS YinelemeSayisi
FROM Iadeler
GROUP BY IadeID
HAVING COUNT(*) > 1

UNION ALL

SELECT 'Kargo', CAST(SiparisID AS NVARCHAR(50)), COUNT(*)
FROM Kargo
GROUP BY SiparisID
HAVING COUNT(*) > 1

UNION ALL

SELECT 'Kategoriler', CAST(KategoriID AS NVARCHAR(50)), COUNT(*)
FROM Kategoriler
GROUP BY KategoriID
HAVING COUNT(*) > 1

UNION ALL

SELECT 'Musteriler', CAST(MusteriID AS NVARCHAR(50)), COUNT(*)
FROM Musteriler
GROUP BY MusteriID
HAVING COUNT(*) > 1

UNION ALL

SELECT 'Sehirler', CAST(SehirID AS NVARCHAR(50)), COUNT(*)
FROM Sehirler
GROUP BY SehirID
HAVING COUNT(*) > 1

UNION ALL

SELECT 'Siparisler', CAST(SiparisID AS NVARCHAR(50)), COUNT(*)
FROM Siparisler
GROUP BY SiparisID
HAVING COUNT(*) > 1

UNION ALL

SELECT 'SiparisDetaylari', CAST(SiparisDetayID AS NVARCHAR(50)), COUNT(*)
FROM SiparislerDetaylari
GROUP BY SiparisDetayID
HAVING COUNT(*) > 1

UNION ALL

SELECT 'Urunler', CAST(UrunID AS NVARCHAR(50)), COUNT(*)
FROM Urunler
GROUP BY UrunID
HAVING COUNT(*) > 1;
GO
/*
   Tablolar arasý iliþki kalitesi kontrolleri 

   Bu sorgu, tablolar arasýnda eþleþmeyen kayýt olup olmadýðýný kontrol eder.

   Örneðin:
   - Sipariþ detayýndaki SiparisID, Siparisler tablosunda var mý?
   - Müþterideki SehirID, Sehirler tablosunda var mý?
   - Sipariþ detayýndaki UrunID, Urunler tablosunda var mý?
   - Kargo tablosundaki SiparisID, Siparisler tablosunda var mý?
   - Ýade tablosundaki SiparisDetayID, SiparisDetaylari tablosunda var mý?

   Sonuçlarýn 0 gelmesi, iliþkisel veri kalitesinin iyi olduðunu gösterir.
 */
SELECT
    (
        SELECT COUNT(*)
        FROM SiparislerDetaylari sd
        LEFT JOIN Siparisler s
            ON sd.SiparisID = s.SiparisID
        WHERE s.SiparisID IS NULL
    ) AS EslesmeyenSiparisDetaySayisi,

    (
        SELECT COUNT(*)
        FROM Siparisler s
        LEFT JOIN Musteriler m
            ON s.MusteriID = m.MusteriID
        WHERE m.MusteriID IS NULL
    ) AS EslesmeyenMusteriSayisi,

    (
        SELECT COUNT(*)
        FROM Musteriler m
        LEFT JOIN Sehirler se
            ON m.SehirID = se.SehirID
        WHERE se.SehirID IS NULL
    ) AS EslesmeyenSehirSayisi,

    (
        SELECT COUNT(*)
        FROM SiparislerDetaylari sd
        LEFT JOIN Urunler u
            ON sd.UrunID = u.UrunID
        WHERE u.UrunID IS NULL
    ) AS EslesmeyenUrunSayisi,

    (
        SELECT COUNT(*)
        FROM Urunler u
        LEFT JOIN Kategoriler k
            ON u.KategoriID = k.KategoriID
        WHERE k.KategoriID IS NULL
    ) AS EslesmeyenKategoriSayisi,

    (
        SELECT COUNT(*)
        FROM Kargo kg
        LEFT JOIN Siparisler s
            ON kg.SiparisID = s.SiparisID
        WHERE s.SiparisID IS NULL
    ) AS EslesmeyenKargoSayisi,

    (
        SELECT COUNT(*)
        FROM Iadeler i
        LEFT JOIN SiparislerDetaylari sd
            ON i.SiparisDetayID = sd.SiparisDetayID
        WHERE sd.SiparisDetayID IS NULL
    ) AS EslesmeyenIadeSayisi;
GO
/* 
   Ham para formatý kontrolü 

   Bu sorgu, satýþ detaylarý tablosundaki para alanlarýnýn
   import sonrasý ham formatýný gösterir.

   Bu alanlar Türkçe para formatý içerdiði için önce metin olarak alýnmýþtýr.
   Daha sonra 03_cleaning_function.sql ve 04_clean_views.sql dosyalarýnda
   DECIMAL veri tipine dönüþtürülmüþtür.
*/
SELECT TOP 20
    BirimFiyat,
    IndirimTutari,
    NetSatisTutari,
    BirimMaliyet,
    ToplamMaliyet,
    BrutKar
FROM SiparislerDetaylari;
GO

/* 
   Ürün fiyat alanlarý ham format kontrolü 

   Bu sorgu, Urunler tablosundaki fiyat ve maliyet alanlarýnýn
   ham formatýný kontrol eder.
*/
SELECT TOP 20
    ListeFiyati,
    BirimMaliyet
FROM Urunler;
GO

/* 
   Takvim tarih formatý kontrolü 

   Bu sorgu, Takvim tablosundaki tarih alanlarýnýn ham formatýný gösterir.

   Tarih alanlarý import sýrasýnda metin olarak alýnmýþtýr.
   Daha sonra clean view içinde TRY_CONVERT ile DATE veri tipine çevrilmiþtir.
 */
SELECT TOP 20
    Tarih,
    [Yýl],
    [YýlAy]
FROM Takvim;
GO

/* 
    Kargo verileri ham format kontrolü

   Bu sorgu, Kargo tablosundaki tarih ve maliyet alanlarýnýn
   ham formatýný kontrol eder.

   TeslimTarihi alanýnda bazý NULL deðerlerin olmasý normaldir.
   Çünkü teslim edilmemiþ veya kargoda olan sipariþlerde teslim tarihi
   henüz oluþmamýþtýr.
 */
SELECT TOP 20
    KargoMaliyeti,
    KargoyaVerilmeTarihi,
    TeslimatDurumu,
    TeslimTarihi
FROM Kargo;
GO