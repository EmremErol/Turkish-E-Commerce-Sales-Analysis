USE ETicaretDB
GO

CREATE OR ALTER FUNCTION fn_TutarTemizle_TR
(
    @value NVARCHAR(100)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @clean NVARCHAR(100);

    SET @clean = LTRIM(RTRIM(@value));

    SET @clean = REPLACE(@clean, N'₺', N'');
    SET @clean = REPLACE(@clean, N'TL', N'');
    SET @clean = REPLACE(@clean, N' ', N'');
    SET @clean = REPLACE(@clean, NCHAR(160), N'');

    -- Turkish money format:
    -- ₺14.700 -> 14700
    -- 149,90  -> 149.90
    SET @clean = REPLACE(@clean, N'.', N'');
    SET @clean = REPLACE(@clean, N',', N'.');

    RETURN TRY_CONVERT(DECIMAL(18,2), @clean);
END;
GO

--Temizleme fonksiyonunu test ettiö 


SELECT
	dbo.fn_TutarTemizle_TR(N'₺14.700') AS Test_1,
    dbo.fn_TutarTemizle_TR(N'149,90') AS Test_2,
    dbo.fn_TutarTemizle_TR(N'TL 2.500') AS Test_3,
    dbo.fn_TutarTemizle_TR(N'₺-') AS Test_4;
GO