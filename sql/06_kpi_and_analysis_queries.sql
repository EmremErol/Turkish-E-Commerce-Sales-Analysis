USE ETicaretDB
GO

--Kaç farklý sipariþte iade var?
SELECT 
	COUNT(DISTINCT SiparisID) AS ToplamSiparis,

	COUNT(DISTINCT CASE
		WHEN IadeMi = 1 THEN SiparisID
	END) AS IadeliSiparisSayisi,

	CAST(
		COUNT(DISTINCT CASE WHEN IadeMi = 1 THEN SiparisID END) * 100.0
		/ NULLIF(COUNT(DISTINCT SiparisID), 0)
		AS DECIMAL(10,2)
	) AS IadeliSiparisOraniYuzde

FROM vw_ETicaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý';

/* Bu sorgu bizim dashboard üst kartlarýnýn SQL karþýlýðý:
Toplam Sipariþ
Toplam Müþteri
Toplam Ürün
Toplam Satýþ
Toplam Maliyet
Toplam Brüt Kâr
Brüt Kâr Marjý
Ýade Oraný */
SELECT
	COUNT(DISTINCT SiparisID) AS ToplamSiparis,
	COUNT(DISTINCT MusteriID) AS ToplamMusteri,
	COUNT(DISTINCT UrunID) AS ToplamUrun,
	SUM(Adet) AS ToplamSatilanAdet,
	SUM(NetSatisTutari) AS ToplamSatis,
	SUM(ToplamMaliyet) AS ToplamMaliyet,
	SUM(BrutKar) AS ToplamBrutKar,
	SUM(IndirimTutari) AS ToplamIndirim,

	CAST(
		SUM(BrutKar) * 100.0 / NULLIF(SUM(NetSatisTutari), 0)
		AS DECIMAL(10,2)
	) AS BrutKarMarjiYüzde,

	SUM(IadeMi) AS IadeSayisi,

	CAST(
		SUM(IadeMi) * 100.0 / NULLIF(COUNT(SiparisID), 0)
		AS DECIMAL(10,2)
	) AS IadeOraniYuzde

FROM vw_ETicaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý';


--Kategori performansý
SELECT
	KategoriAdi,
	COUNT(DISTINCT SiparisID) AS SiparisSayisi,
	COUNT(DISTINCT UrunID) AS UrunSayisi,
	SUM(Adet) AS ToplamSatilanAdet,
	SUM(NetSatisTutari) AS ToplamSatis,
	SUM(ToplamMaliyet) AS ToplamMaliyet,
	SUM(BrutKar) AS ToplamBrutKar
FROM vw_ETicaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý'
GROUP BY KategoriAdi
ORDER BY ToplamSatis DESC;

--En çok satan ürünler
SELECT 
	UrunAdi,
	KategoriAdi,
	Marka,
	COUNT(DISTINCT SiparisID) AS SiparisSayisi,
	SUM(Adet) AS ToplamSatianAdet,
	SUM(NetSatisTutari) AS ToplamSatis,
	SUM(BrutKar) ToplamBrutKar,

	CAST(
		SUM(BrutKar) * 100.0 / NULLIF(SUM(NetSatisTutari), 0)
		AS DECIMAL(10,2)
	) AS BrutKarMarjiYuzde
FROM vw_Eticaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý'
GROUP BY UrunAdi, KategoriAdi, Marka
ORDER BY ToplamSatis DESC;


-- Marka performansý
SELECT
	Marka,
	COUNT(DISTINCT SiparisID) AS SiparisSayisi,
	COUNT(DISTINCT UrunID) AS UrunSayisi,
	SUM(Adet) AS ToplamAdet,
	SUM(NetSatisTutari) AS ToplamSatis,
	SUM(BrutKar) AS TopamBrutKar,

	CAST(
		SUM(BrutKar) * 100.0 / NULLIF(SUM(NetSatisTutari),0)
		AS DECIMAL(10,2)
	)AS BrutKarMarjiYuzde
FROM vw_Eticaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý'
GROUP BY Marka
ORDER BY ToplamSatis DESC;


--Aylýk satiþ trendi
SELECT
	Yil,
	AyNo,
	Ay,
	YilAy,
	COUNT(DISTINCT SiparisID) AS SiparisSayisi,
	SUM(Adet) AS ToplamSatilanAdet,
	SUM(NetSatisTutari) AS ToplamSatis,
	SUM(BrutKar) AS ToplamBrutKar,

	CAST(
		SUM(BrutKar) * 100.0 / NULLIF(SUM(NetSatisTutari), 0)
		AS DECIMAL(10,2)
	) AS BrutKarMarjiYuzde

FROM vw_Eticaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý'
GROUP BY Yil, AyNo, Ay, YilAy
ORDER BY Yil, AyNo;


--Müþteri segmenti analizi
SELECT
    MusteriSegmenti,
    COUNT(DISTINCT MusteriID) AS MusteriSayisi,
    COUNT(DISTINCT SiparisID) AS SiparisSayisi,
    SUM(NetSatisTutari) AS ToplamSatis,
    SUM(BrutKar) AS ToplamBrutKar,

    CAST(
        SUM(NetSatisTutari) * 1.0 / NULLIF(COUNT(DISTINCT MusteriID), 0)
        AS DECIMAL(18,2)
    ) AS MusteriBasinaSatis,

    CAST(
        SUM(BrutKar) * 100.0 / NULLIF(SUM(NetSatisTutari), 0)
        AS DECIMAL(10,2)
    ) AS BrutKarMarjiYuzde

FROM vw_Eticaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý'
GROUP BY MusteriSegmenti
ORDER BY ToplamSatis DESC;


--Cinsiyet bazlý müþteri analizi
SELECT
	Cinsiyet,
	COUNT(DISTINCT MusteriID) AS MusteriSayisi,
	COUNT(DISTINCT SiparisID) AS SiparisSayisi,
	SUM(NetSatisTutari) AS ToplamSatis,
	SUM(BrutKar) AS ToplamBrutKar,

	CAST(
		SUM(NetSatisTutari) * 1.0 / NULLIF(COUNT(DISTINCT SiparisID),0)
		AS DECIMAL(10,2)
	) AS OrtalamaSiparisTutari

FROM vw_Eticaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý'
GROUP BY Cinsiyet
ORDER BY ToplamSatis DESC;


--Yaþ grubu analizi
SELECT
	CASE
		WHEN Yas < 25 THEN '18-24'
		WHEN Yas BETWEEN 25 AND 34 THEN '25-34'
		WHEN Yas BETWEEN 35 AND 44 THEN '35-44'
		WHEN Yas BETWEEN 45 AND 54 THEN '45-54'
		ELSE '55+'
	END AS YasGrubu,
	
	COUNT(DISTINCT MusteriID) AS MusteriSayisi,
	COUNT(DISTINCT SiparisID) AS SiparisSayisi,
	SUM(NetSatisTutari) AS ToplamSatis,
	SUM(BrutKar) AS ToplamBrutKar

FROM vw_Eticaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý'
GROUP BY 
	CASE
		WHEN Yas < 25 THEN '18-24'
		WHEN Yas BETWEEN 25 AND 34 THEN '25-34'
		WHEN Yas BETWEEN 35 AND 44 THEN '35-44'
		WHEN Yas BETWEEN 45 AND 54 THEN '45-54'
		ELSE '55+'
	END
ORDER BY ToplamSatis DESC;


--Þehir bölge sayýsý
SELECT 
	Bolge, 
	Sehir,
	COUNT(DISTINCT MusteriID) AS MusteriSayisi,
	COUNT(DISTINCT SiparisID) AS SiparisSayisi,
	SUM(NetSatisTutari) AS ToplamSatis,
	SUM(BrutKar) ToplamBrutKar,
	 
	CAST(
		SUM(NetSatisTutari) * 1.0 / NULLIF(COUNT(DISTINCT SiparisID), 0)
		AS DECIMAL(10,2)
	)AS OrtalamaSiparisTutari

FROM vw_Eticaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý'
GROUP BY Bolge, Sehir
ORDER BY ToplamSatis DESC;


--Satýþ kanalý analizi
SELECT
	SatisKanali,
	COUNT(DISTINCT SiparisID) AS SiparisSayisi,
	COUNT(DISTINCT MusteriID) AS MusteriSayisi,
	SUM(NetSatisTutari) AS ToplamSatis,
	SUM(BrutKar) AS ToplamBrutKar,

	CAST(
		SUM(NetSatisTutari) * 1.0 / NULLIF(COUNT(DISTINCT SiparisID), 0)
		AS DECIMAL(10,2)
	)AS OrtalamaSiparisTutari

FROM vw_Eticaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý'
GROUP BY SatisKanali
ORDER BY ToplamSatis DESC;


--Ödeme yöntemi analizi
SELECT 
	OdemeYontemi,
	COUNT(DISTINCT SiparisID) AS SiparisSayisi,
	SUM(NetSatisTutari) AS ToplamSatis,
	SUM(BrutKar) AS ToplamBrutKar,

	CAST(
		SUM(NetSatisTutari) * 1.0 / NULLIF(COUNT(DISTINCT SiparisID),  0)
		AS DECIMAL(10,2)
	)AS OrtalamaSiparisTutari
FROM vw_Eticaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý'
GROUP BY OdemeYontemi 
ORDER BY ToplamSatis DESC;


--Kargo Performansý
SELECT 
	KargoFirmasi,
	TeslimatDurumu,
	COUNT(DISTINCT SiparisID) AS SiparisSayisi,
	SUM(KargoMaliyeti) ToplamKargoMaliyeti,
	AVG(KargoMaliyeti) AS OrtalamaKargoMaliyeti,

	AVG(
		CASE
			WHEN KargoyaVerilmeTarihi IS NOT NULL
			AND TeslimTarihi IS NOT NULL
			THEN DATEDIFF(DAY, KargoyaVerilmeTarihi, TeslimTarihi)
		END
	) AS OrtalamaTeslimatSuresi

FROM vw_Eticaret_SatisAnalizi
GROUP BY KargoFirmasi, TeslimatDurumu
ORDER BY SiparisSayisi DESC;


--Ýade nedeni analizi
SELECT	
	IadeNedeni,
	COUNT(*) AS IadeSatirSayisi

FROM vw_Eticaret_SatisAnalizi
WHERE IadeMi = 1
GROUP BY IadeNedeni
ORDER BY IadeSatirSayisi DESC;



--Kategori bazlý iade oraný
SELECT 
	KategoriAdi,
	COUNT(SiparisDetayID) AS ToplamSatisSatiri,
	SUM(IadeMi) AS IadeSatirSayisi,

	CAST(
		SUM(IadeMi) * 100.0 / NULLIF(COUNT(SiparisDetayID), 0)
		AS DECIMAL(10,2)
	) AS IadeOraniYuzde,

	SUM(NetSatisTutari) AS ToplamSatis

FROM vw_Eticaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý'
GROUP BY KategoriAdi
ORDER BY IadeOraniYuzde DESC;


--En karlý urunler
SELECT
	UrunAdi,
	KategoriAdi,
	Marka,
	SUM(NetSatisTutari) AS ToplamSatis,
	SUM(BrutKar) AS ToplamBrutKar,

	CAST(
		SUM(BrutKar) * 100.0 / NULLIF(SUM(NetSatisTutari),0)
		AS DECIMAL(10,2)
		) AS BrutKarMarjiYuzde

FROM vw_Eticaret_SatisAnalizi
WHERE SiparisDurumu = 'Tamamlandý'
GROUP BY UrunAdi, KategoriAdi, Marka
ORDER BY ToplamBrutKar DESC;




















































