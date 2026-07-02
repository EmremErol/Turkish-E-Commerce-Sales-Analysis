-- Bu sorgu bize SQL’e gelen tabloları gösterecek
USE ETicaretDB;
GO

SELECT 
    name AS TableName,
    create_date,
    modify_date
FROM sys.tables
ORDER BY name;


-- Tablolardaki satır sayıları

SELECT 'Iadeler' AS  Tablo , COUNT(*) AS SatırSayisi FROM Iadeler
UNION ALL
SELECT 'Kargo' , COUNT(*) FROM Kargo
UNION ALL
SELECT 'Kategoriler' , COUNT(*) FROM Kategoriler
UNION ALL
SELECT 'Musteriler' , COUNT(*) FROM Musteriler
UNION ALL 
SELECT 'Sehirler' , COUNT(*) FROM Sehirler
UNION ALL
SELECT 'Siparisler' , COUNT(*) FROM Siparisler
UNION ALL
SELECT 'SiparislerDetaylari' , COUNT(*) FROM SiparislerDetaylari
UNION ALL
SELECT 'Takvim' , COUNT(*) FROM Takvim
UNION ALL
SELECT 'Urunler' , COUNT(*) FROM Urunler;

--Kolon tipleri
SELECT 
	TABLE_NAME AS Tablo,
	COLUMN_NAME AS Kolon,
	DATA_TYPE AS VeriTipi,
	CHARACTER_MAXIMUM_LENGTH AS Uzunluk,
	IS_NULLABLE BosGecerMi
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT TOP 10 * FROM Kargo;
SELECT TOP 10 * FROM Siparisler;
SELECT TOP 10 * FROM SiparislerDetaylari;
SELECT TOP 10 * FROM Takvim;
SELECT TOP 10 * FROM Urunler;

-- temizleme fonksiyonu
CREATE OR ALTER FUNCTION fn_TutarTemizle_TR
(
	@value NVARCHAR(100)
)
RETURNS DECIMAL(18,2)
AS 
BEGIN 
		DECLARE @clean NVARCHAR(100);

		SET @clean = LTRIM(RTRIM(@value));

		SET @clean = REPLACE(@clean, N'₺' , N'');
		SET @clean = REPLACE(@clean, N'TL', N'');
		SET @clean = REPLACE(@clean, N' ', N'');
		SET @clean = REPLACE(@clean, NCHAR(160), N'');

		--Türkçe sayı formatı:
		--14.700,50 ->14700.50
		SET @clean = REPLACE(@clean, N'.', N'');
		SET @clean = REPLACE(@clean, N',', N'.');

		RETURN TRY_CONVERT(DECIMAL(18,2), @clean);
END;

CREATE OR ALTER VIEW vw_SiparisDetaylari_Clean AS
SELECT
    SiparisDetayID,
    SiparisID,
    UrunID,
    UrunAdi,
    KategoriID,
    KategoriAdi,
    Adet,

    dbo.fn_TutarTemizle_TR(BirimFiyat) AS BirimFiyat,

    TRY_CONVERT(
        DECIMAL(5,2),
        REPLACE(REPLACE(REPLACE(IndirimOrani, N'%', N''), N',', N'.'), N' ', N'')
    ) AS IndirimOrani,

    dbo.fn_TutarTemizle_TR(IndirimTutari) AS IndirimTutari,
    dbo.fn_TutarTemizle_TR(NetSatisTutari) AS NetSatisTutari,
    dbo.fn_TutarTemizle_TR(BirimMaliyet) AS BirimMaliyet,
    dbo.fn_TutarTemizle_TR(ToplamMaliyet) AS ToplamMaliyet,
    dbo.fn_TutarTemizle_TR(BrutKar) AS BrutKar

FROM SiparislerDetaylari;
GO

CREATE OR ALTER VIEW vw_Urunler_Clean AS
SELECT
	UrunID,
	UrunAdi,
	KategoriID,
	KategoriAdi,
	Marka,
	dbo.fn_TutarTemizle_TR(ListeFiyati) AS ListeFiyati,
	dbo.fn_TutarTemizle_TR(BirimMaliyet) AS BirimMaliyet
FROM Urunler;
GO

CREATE OR ALTER VIEW vw_Takvim_Clean AS
SELECT
	TRY_CONVERT(DATE, Tarih, 104) AS Tarih,
	Yil,
	AyNo,
	AyAdi,
	Ceyrek,
	HaftaGunu,
	HaftaSonuMu,
	YılAy
FROM Takvim;
GO

CREATE OR ALTER VIEW vw_Kargo_Clean AS
SELECT
	SiparisID,
	KargoFirmasi,
	KargoyaVerilmeTarihi,
	TeslimatDurumu,
	dbo.fn_TutarTemizle_TR(KargoMaliyeti) AS KargoMaliyeti,
	TeslimTarihi
FROM Kargo;
GO

SELECT TOP 10 * FROM vw_SiparisDetaylari_Clean;
SELECT TOP 10 * FROM vw_Urunler_Clean;
SELECT TOP 10 * FROM vw_Takvim_Clean;
SELECT TOP 10 * FROM vw_Kargo_Clean;

SELECT * FROM vw_SiparisDetaylari_Clean;

--VIEW çalışıyor mu 
SELECT TOP 10
	SiparisDetayID,
	SiparisID,
	UrunID,
	KategoriID,
	UrunAdi,
	KategoriID,
	KategoriAdi,
	Adet,
	BirimFiyat,
	NetSatisTutari,
	ToplamMaliyet,
	BrutKar
FROM vw_SiparisDetaylari_Clean;

--Bu satış detaylarında toplam kaç satır var, kaç ürün satılmış, toplam satış ve kâr ne?
SELECT 
	COUNT(*) AS SatirSayisi,
	SUM(Adet) AS ToplamSatilanAdet,
	SUM(NetSatisTutari) AS ToplamSatis,
	SUM(ToplamMaliyet) AS ToplamMaliyet,
	SUM(BrutKar) AS ToplamBrutKar
FROM vw_SiparisDetaylari_Clean;


SELECT 
	KategoriAdi,
	SUM(Adet) ToplamSatilanAdet,
	SUM(NetSatisTutari) ToplamSatis,
	SUM(BrutKar) ToplamBrutKar
FROM vw_SiparisDetaylari_Clean
GROUP BY KategoriAdi
ORDER BY ToplamSatis DESC;


SELECT TOP 20
	sd.SiparisDetayID,
	sd.SiparisID,
	s.SiparisTarihi,
	s.SiparisDurumu,
	s.SatisKanali,
	sd.UrunAdi,
	sd.KategoriAdi,
	sd.Adet,
	sd.NetSatisTutari,
	sd.BrutKar
FROM vw_SiparisDetaylari_Clean sd
LEFT JOIN Siparisler s
 ON sd.SiparisID = s.SiparisID;

 -- Satış Kanalı Performansı Mobil Uygulama / Web Sitesi / Pazaryeri 
 SELECT
	s.SatisKanali,
	COUNT(DISTINCT s.SiparisID) SiparisSayisi,
	SUM(sd.Adet) ToplamSatilanAdet,
	SUM(sd.NetSatisTutari) ToplamSatis,
	SUM(sd.BrutKar) ToplamBrutKar 
 FROM vw_SiparisDetaylari_Clean sd
 LEFT JOIN Siparisler s
	ON sd.SiparisID = s.SiparisID
WHERE s.SiparisDurumu = 'Tamamlandı'
GROUP BY s.SatisKanali
ORDER BY ToplamSatis DESC ;

