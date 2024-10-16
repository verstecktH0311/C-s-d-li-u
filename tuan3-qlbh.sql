USE QUANLYBANHANG
SET DATEFORMAT DMY;

-- III. Ngôn ngữ truy vấn dữ liệu có cấu trúc:
-- 12.	Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20.
SELECT DISTINCT SOHD FROM CTHD 
WHERE MASP IN ('BB01', 'BB02') AND SL BETWEEN 10 AND 20
GO

-- 13.	Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20.
SELECT SOHD FROM CTHD 
WHERE MASP IN ('BB01', 'BB02') AND SL BETWEEN 10 AND 20
GROUP BY SOHD 
HAVING COUNT(DISTINCT MASP) = 2
GO

-- 14.	In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản phẩm được bán ra trong ngày 1/1/2007.
SELECT MASP, TENSP
FROM SANPHAM 
WHERE NUOCSX = 'Trung Quoc' OR MASP IN (
	SELECT DISTINCT CT.MASP 
	FROM CTHD CT INNER JOIN HOADON HD
	ON CT.SOHD = HD.SOHD
	WHERE NGHD = '01/01/2007'
)
GO

-- 15.	In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
SELECT MASP, TENSP
FROM SANPHAM 
WHERE MASP NOT IN (
	SELECT DISTINCT MASP 
	FROM CTHD
)
GO

-- 16.	In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.
SELECT MASP, TENSP
FROM SANPHAM 
WHERE MASP NOT IN (
	SELECT CT.MASP
	FROM CTHD CT INNER JOIN HOADON HD
	ON CT.SOHD = HD.SOHD
	WHERE YEAR(NGHD) = 2006
)
GO

-- 17.	In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong năm 2006.
SELECT MASP, TENSP
FROM SANPHAM 
WHERE NUOCSX = 'Trung Quoc' AND MASP NOT IN (
	SELECT DISTINCT CT.MASP
	FROM CTHD CT INNER JOIN HOADON HD
	ON CT.SOHD = HD.SOHD
	WHERE YEAR(NGHD) = 2006
)
GO

-- 18.	Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất.
SELECT CT.SOHD
FROM CTHD CT INNER JOIN SANPHAM SP
ON CT.MASP = SP.MASP
WHERE NUOCSX = 'Singapore'
GROUP BY CT.SOHD 
HAVING COUNT(DISTINCT CT.MASP) = (
	SELECT COUNT(MASP) 
	FROM SANPHAM 
	WHERE NUOCSX = 'Singapore'
)
GO
