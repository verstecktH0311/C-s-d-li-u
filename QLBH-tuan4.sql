SET DATEFORMAT DMY;
USE QUANLYBANHANG;

-- 19.	Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất.
SELECT SOHD 
FROM HOADON
WHERE YEAR(NGHD) = 2006 AND SOHD IN (
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
);

-- 20.	Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
SELECT COUNT(*) FROM HOADON
WHERE MAKH NOT IN(
	SELECT MAKH FROM KHACHHANG 
	WHERE KHACHHANG.MAKH = HOADON.MAKH
);

-- 21.	Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.
SELECT COUNT(DISTINCT MASP) 
FROM CTHD CT INNER JOIN HOADON HD
ON CT.SOHD = HD.SOHD
WHERE YEAR(NGHD) = '2006';

-- 22.	Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu ?
SELECT MIN(TRIGIA) GIAMIN, MAX(TRIGIA) GIAMAX FROM HOADON;

-- 23.	Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
SELECT AVG(TRIGIA) FROM HOADON WHERE YEAR(NGHD) = '2006';

-- 24.	Tính doanh thu bán hàng trong năm 2006.
SELECT SUM(TRIGIA) FROM HOADON WHERE YEAR(NGHD) = '2006';

-- 25.	Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
SELECT SOHD FROM HOADON
WHERE YEAR(NGHD) = '2006' AND TRIGIA = (
	SELECT MAX(TRIGIA) FROM HOADON
);

-- 26.	Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
SELECT HOTEN FROM HOADON HD INNER JOIN KHACHHANG KH
ON HD.MAKH = KH.MAKH
WHERE YEAR(NGHD) = '2006' AND TRIGIA = (
	SELECT MAX(TRIGIA) FROM HOADON
);

-- 27.	In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất.
SELECT TOP 3 MAKH, HOTEN FROM KHACHHANG ORDER BY DOANHSO DESC;

-- 28.	In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.
SELECT MASP, TENSP FROM SANPHAM
WHERE GIA IN(
	SELECT DISTINCT TOP 3 GIA FROM SANPHAM
	ORDER BY GIA DESC
);

-- 29.	In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của tất cả các sản phẩm).
SELECT MASP, TENSP FROM SANPHAM
WHERE NUOCSX = 'Thai Lan' AND GIA IN(
	SELECT DISTINCT TOP 3 GIA FROM SANPHAM
	ORDER BY GIA DESC
);

-- 30.	In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).
SELECT MASP, TENSP FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' AND GIA IN(
	SELECT DISTINCT TOP 3 GIA FROM SANPHAM
	WHERE NUOCSX = 'Trung Quoc'
	ORDER BY GIA DESC
); 

-- 31.	* In ra danh sách 3 khách hàng có doanh số cao nhất (sắp xếp theo kiểu xếp hạng).
SELECT TOP 3 MAKH, HOTEN, RANK() OVER (ORDER BY DOANHSO DESC) RANK_KH FROM KHACHHANG;

-- 32.	Tính tổng số sản phẩm do “Trung Quoc” sản xuất.
SELECT COUNT(MASP) FROM SANPHAM WHERE NUOCSX = 'Trung Quoc';

-- 33.	Tính tổng số sản phẩm của từng nước sản xuất.
SELECT NUOCSX, COUNT(MASP) SOSP FROM SANPHAM GROUP BY NUOCSX;

-- 34.	Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm.
SELECT NUOCSX, MAX(GIA) GIAMAX, MIN(GIA) GIAMIN, AVG(GIA) TRUNGBINH FROM SANPHAM GROUP BY NUOCSX;

-- 35.	Tính doanh thu bán hàng mỗi ngày.
SELECT NGHD, SUM(TRIGIA) DOANHTHU FROM HOADON GROUP BY NGHD;

-- 36.	Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
SELECT  CT.MASP, SUM(SL) SL
FROM CTHD CT INNER JOIN HOADON HD 
ON CT.SOHD = HD.SOHD
WHERE YEAR(NGHD) = '2006' AND MONTH(NGHD) = '10'
GROUP BY CT.MASP;

-- 37.	Tính doanh thu bán hàng của từng tháng trong năm 2006.
SELECT MONTH(NGHD) THANG, SUM(TRIGIA) DOANHTHU
FROM HOADON 
WHERE YEAR(NGHD) = '2006'
GROUP BY MONTH(NGHD);

-- 38.	Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
SELECT SOHD FROM CTHD
GROUP BY SOHD 
HAVING COUNT(DISTINCT MASP) >= 4;

-- 39.	Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
SELECT SOHD FROM CTHD CT INNER JOIN SANPHAM SP
ON CT.MASP = SP.MASP
WHERE NUOCSX = 'Viet Nam'
GROUP BY SOHD 
HAVING COUNT(DISTINCT CT.MASP) = 3;

-- 40.	Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất. 
SELECT MAKH, HOTEN FROM (
	SELECT HD.MAKH, HOTEN, RANK() OVER (ORDER BY COUNT(HD.MAKH) DESC) RANK_SOLAN 
	FROM HOADON HD INNER JOIN KHACHHANG KH 
	ON HD.MAKH = KH.MAKH
	GROUP BY HD.MAKH, HOTEN
) A
WHERE RANK_SOLAN = 1;

-- 41.	Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ?
SELECT THANG FROM (
	SELECT MONTH(NGHD) THANG, RANK() OVER (ORDER BY SUM(TRIGIA) DESC) RANK_TRIGIA FROM HOADON
	WHERE YEAR(NGHD) = '2006' 
	GROUP BY MONTH(NGHD)
) A
WHERE RANK_TRIGIA = 1;

-- 42.	Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
SELECT A.MASP, TENSP FROM (
	SELECT MASP, RANK() OVER (ORDER BY SUM(SL)) RANK_SL
	FROM CTHD CT INNER JOIN HOADON HD
	ON CT.SOHD = HD.SOHD
	WHERE YEAR(NGHD) = '2006'
	GROUP BY MASP
) A INNER JOIN SANPHAM SP
ON A.MASP = SP.MASP
WHERE RANK_SL = 1;

-- 43.	*Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.
SELECT NUOCSX, MASP, TENSP FROM (
	SELECT NUOCSX, MASP, TENSP, GIA, RANK() OVER (PARTITION BY NUOCSX ORDER BY GIA DESC) RANK_GIA FROM SANPHAM
) A 
WHERE RANK_GIA = 1;

-- 44.	Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.
SELECT NUOCSX FROM SANPHAM 
GROUP BY NUOCSX
HAVING COUNT(DISTINCT GIA) >= 3;

-- 45.	*Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.
SELECT MAKH, HOTEN FROM (
	SELECT TOP 10 HD.MAKH, HOTEN, DOANHSO, RANK() OVER (ORDER BY COUNT(HD.MAKH) DESC) RANK_SOLAN 
	FROM HOADON HD INNER JOIN KHACHHANG KH 
	ON HD.MAKH = KH.MAKH
	GROUP BY HD.MAKH, HOTEN, DOANHSO
	ORDER BY DOANHSO DESC
) A
WHERE RANK_SOLAN = 1;