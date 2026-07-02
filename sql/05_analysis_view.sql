
USE ETicaretDB
GO
CREATE OR ALTER VIEW vw_ETicaret_SatisAnalizi AS
SELECT
	-- Satış detay bilgieri
	sd.SiparisDetayID,
	sd.SiparisID,
	sd.UrunID,
	sd.UrunAdi,
	sd.KategoriID,
	sd.KategoriAdi,
	sd.Adet,
	sd.BirimFiyat,
	sd.IndirimOrani,
	ISNULL(sd.IndirimTutari, 0) AS IndirimTutari,
	sd.NetSatisTutari,
	sd.BirimMaliyet,
	sd.ToplamMaliyet,
	sd.BrutKar,

	--Sipariş bilgileri
	s.MusteriID,
	s.SiparisTarihi,
	s.YılAy AS YilAy,
	s.Yıl AS Yil,
	s.AyNo,
	s.Ay,
	s.OdemeYontemi,
	s.SiparisDurumu,
	s.SatisKanali,

	--Müşteri bilgileri
	m.Ad,
	m.Soyad,
	m.AdSoyad,
	m.Cinsiyet,
	m.Yas,
	m.MusteriSegmenti,
	m.SehirID,
	m.Sehir,

	--Şehir / Bölge isimleri
	se.Bolge,

	--Urun bilgileri
	u.Marka,
	u.ListeFiyati,
	u.BirimMaliyet AS UrunBirimMaliyet,

	--Takvim bilgileri
	t.Ceyrek,
	t.HaftaGunu,
	t.HaftaSonuMu,

	--Kargo bilgileri
	k.KargoFirmasi,
	k.KargoyaVerilmeTarihi,
	k.TeslimatDurumu,
	k.KargoMaliyeti,
	k.TeslimTarihi,

	--İade bilgileri 
	CASE
		WHEN i.IadeID IS NOT NULL THEN 1
		ELSE 0
	END AS IadeMi,

	i.IadeID,
	i.IadeTarihi,
	i.IadeNedeni,
	i.IadeDurumu

FROM vw_SiparisDetaylari_Clean AS sd

LEFT JOIN Siparisler AS s
	ON sd.SiparisID = s.SiparisID

LEFT JOIN Musteriler AS m
	ON s.MusteriID = m.MusteriID

LEFT JOIN Sehirler AS se
	ON m.SehirID = se.SehirID

LEFT JOIN vw_Urunler_Clean AS u
	ON sd.UrunID = u.UrunID

LEFT JOIN vw_Takvim_Clean AS t
	ON s.SiparisTarihi = t.Tarih

LEFT JOIN dbo.vw_Kargo_Clean AS k
	ON s.SiparisID = k.SiparisID

LEFT JOIN  Iadeler  AS i
	ON sd.SiparisDetayID = i.SiparisDetayID;
