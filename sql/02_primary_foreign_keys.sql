USE ETicaretDB;
GO

--Deðiþmez alanlarýný ekledim Primary key 
ALTER TABLE Iadeler
ADD CONSTRAINT PK_Iadeler PRIMARY KEY (IadeID);
GO

ALTER TABLE Kargo
ADD CONSTRAINT PK_Kargo PRIMARY KEY (SiparisID);
GO

ALTER TABLE Kategoriler
ADD CONSTRAINT PK_Kategoriler PRIMARY KEY (KategoriID);
GO

ALTER TABLE Musteriler
ADD CONSTRAINT PK_Musteriler PRIMARY KEY (MusteriID);
GO

ALTER TABLE Sehirler
ADD CONSTRAINT PK_Sehirler PRIMARY KEY (SehirID);
GO

ALTER TABLE Siparisler
ADD CONSTRAINT PK_Siparisler PRIMARY KEY (SiparisID);
GO

ALTER TABLE SiparisDetaylari
ADD CONSTRAINT PK_SiparisDetaylari PRIMARY KEY (SiparisDetayID);
GO

ALTER TABLE Urunler
ADD CONSTRAINT PK_Urunler PRIMARY KEY (UrunID);
GO


--Foreign key yardýmci anahtar kullanarak iliþki kuruyoruz 

ALTER TABLE Musteriler
ADD CONSTRAINT FK_Musteriler_Sehirler
FOREIGN KEY (SehirID)
REFERENCES Sehirler(SehirID);
GO

ALTER TABLE Urunler
ADD CONSTRAINT FK_Urunler_Kategoriler
FOREIGN KEY (KategoriID)
REFERENCES Kategoriler(KategoriID);
GO

ALTER TABLE Siparisler
ADD CONSTRAINT FK_Siparisler_Musteriler
FOREIGN KEY (MusteriID)
REFERENCES Musteriler(MusteriID);
GO

ALTER TABLE SiparisDetaylari
ADD CONSTRAINT FK_SiparisDetaylari_Siparisler
FOREIGN KEY (SiparisID)
REFERENCES Siparisler(SiparisID);
GO

ALTER TABLE SiparisDetaylari
ADD CONSTRAINT FK_SiparisDetaylari_Urunler
FOREIGN KEY (UrunID)
REFERENCES Urunler(UrunID);
GO

ALTER TABLE Iadeler
ADD CONSTRAINT FK_Iadeler_SiparisDetaylari
FOREIGN KEY (SiparisDetayID)
REFERENCES SiparisDetaylari(SiparisDetayID);
GO

ALTER TABLE Kargo
ADD CONSTRAINT FK_Kargo_Siparisler
FOREIGN KEY (SiparisID)
REFERENCES Siparisler(SiparisID);
GO


--Kýsýt kontrolü
SELECT
    name AS ConstraintName,
    type_desc AS ConstraintType
FROM sys.objects
WHERE type IN ('PK', 'F')
ORDER BY type_desc, name;
GO