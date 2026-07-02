/* =====================================================
   Turkish E-Commerce Sales Analysis
   04 - Clean Views

   Bu dosyada ham tablolardaki para, oran ve tarih alanları
   analiz için uygun veri tiplerine dönüştürülmüştür.

   Veritabanı: ETicaretDB
   Araçlar: SQL Server, SSMS
===================================================== */

USE ETicaretDB;
GO


/* =====================================================
   01 - SİPARİŞ DETAYLARI CLEAN VIEW

   Amaç:
   Sipariş detayları tablosundaki para ve indirim alanlarını
   analiz için kullanılabilir sayısal değerlere dönüştürmek.
===================================================== */

CREATE OR ALTER VIEW dbo.vw_SiparisDetaylari_Clean AS
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
        REPLACE(
            REPLACE(
                REPLACE(CAST(IndirimOrani AS NVARCHAR(50)), N'%', N''),
                N',', N'.'
            ),
            N' ', N''
        )
    ) AS IndirimOrani,

    dbo.fn_TutarTemizle_TR(IndirimTutari) AS IndirimTutari,
    dbo.fn_TutarTemizle_TR(NetSatisTutari) AS NetSatisTutari,
    dbo.fn_TutarTemizle_TR(BirimMaliyet) AS BirimMaliyet,
    dbo.fn_TutarTemizle_TR(ToplamMaliyet) AS ToplamMaliyet,
    dbo.fn_TutarTemizle_TR(BrutKar) AS BrutKar

FROM dbo.SiparislerDetaylari;
GO


/* =====================================================
   02 - ÜRÜNLER CLEAN VIEW

   Amaç:
   Ürün fiyatı ve birim maliyet alanlarını sayısal formata çevirmek.
===================================================== */

CREATE OR ALTER VIEW dbo.vw_Urunler_Clean AS
SELECT
    UrunID,
    UrunAdi,
    KategoriID,
    KategoriAdi,
    Marka,

    dbo.fn_TutarTemizle_TR(ListeFiyati) AS ListeFiyati,
    dbo.fn_TutarTemizle_TR(BirimMaliyet) AS BirimMaliyet

FROM dbo.Urunler;
GO


/* =====================================================
   03 - TAKVİM CLEAN VIEW

   Amaç:
   Tarih alanını DATE veri tipine dönüştürmek ve takvim alanlarını
   analiz sorgularında kullanılacak şekilde hazırlamak.
===================================================== */

CREATE OR ALTER VIEW dbo.vw_Takvim_Clean AS
SELECT
    TRY_CONVERT(DATE, Tarih, 104) AS Tarih,
    [Yıl] AS Yil,
    AyNo,
    Ay,
    [YılAy] AS YilAy,
    Ceyrek,
    HaftaGunu,
    HaftaSonuMu

FROM dbo.Takvim;
GO


/* =====================================================
   04 - KARGO CLEAN VIEW

   Amaç:
   Kargo maliyeti ve tarih alanlarını analiz için uygun formata çevirmek.
===================================================== */

CREATE OR ALTER VIEW dbo.vw_Kargo_Clean AS
SELECT
    SiparisID,
    KargoFirmasi,
    TRY_CONVERT(DATE, KargoyaVerilmeTarihi, 104) AS KargoyaVerilmeTarihi,
    TeslimatDurumu,
    dbo.fn_TutarTemizle_TR(KargoMaliyeti) AS KargoMaliyeti,
    TRY_CONVERT(DATE, TeslimTarihi, 104) AS TeslimTarihi

FROM dbo.Kargo;
GO


/* =====================================================
   CLEAN VIEW KONTROLLERİ
===================================================== */

SELECT TOP 10 *
FROM dbo.vw_SiparisDetaylari_Clean;
GO

SELECT TOP 10 *
FROM dbo.vw_Urunler_Clean;
GO

SELECT TOP 10 *
FROM dbo.vw_Takvim_Clean;
GO

SELECT TOP 10 *
FROM dbo.vw_Kargo_Clean;
GO
