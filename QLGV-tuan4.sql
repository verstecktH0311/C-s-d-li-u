SET DATEFORMAT DMY;
USE QUANLYGIAOVU;

-- 19.	Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.
SELECT MAKHOA, TENKHOA FROM (
	SELECT MAKHOA, TENKHOA, RANK() OVER (ORDER BY NGTLAP) RANK_NGTLAP FROM KHOA 
) A
WHERE RANK_NGTLAP = 1;

-- 20.	Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
SELECT HOCHAM, COUNT(HOCHAM) SL FROM GIAOVIEN 
WHERE HOCHAM IN ('GS', 'PGS') 
GROUP BY HOCHAM;

-- 21.	Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.
SELECT MAKHOA, HOCVI, COUNT(HOCVI) SL FROM GIAOVIEN 
GROUP BY MAKHOA, HOCVI
ORDER BY MAKHOA;

-- 22.	Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).
SELECT MAMH, KQUA, COUNT(MAHV) SL
FROM KETQUATHI A
WHERE NOT EXISTS (
	SELECT 1 
	FROM KETQUATHI B 
	WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
)
GROUP BY MAMH, KQUA;

-- 23.	Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít nhất một môn học.
SELECT MAGV, HOTEN 
FROM GIAOVIEN 
WHERE MAGV IN(
	SELECT DISTINCT MAGV
	FROM GIANGDAY GD INNER JOIN LOP
	ON GD.MALOP = LOP.MALOP
	WHERE MAGV = MAGVCN 
);

-- 24.	Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
SELECT HO + ' ' + TEN HOTEN FROM LOP INNER JOIN HOCVIEN HV
ON LOP.TRGLOP = HV.MAHV
WHERE SISO = (
	SELECT MAX(SISO) FROM LOP
);

-- 25.	* Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần thi).
SELECT HO + ' ' + TEN HOTEN FROM HOCVIEN
WHERE MAHV IN (
	SELECT MAHV FROM KETQUATHI A
	WHERE MAHV IN (
		SELECT TRGLOP FROM LOP
	) AND NOT EXISTS (
		SELECT 1 FROM KETQUATHI B 
		WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
	) AND KQUA = 'Khong Dat'
	GROUP BY MAHV
	HAVING COUNT(MAMH) >= 3
);

-- 26.	Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
SELECT A.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT MAHV, RANK () OVER (ORDER BY COUNT(MAMH) DESC) RANK_MH FROM KETQUATHI KQ 
	WHERE DIEM BETWEEN 9 AND 10
	GROUP BY KQ.MAHV
) A INNER JOIN HOCVIEN HV
ON A.MAHV = HV.MAHV
WHERE RANK_MH = 1;

-- 27.	Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
SELECT LEFT(A.MAHV, 3) MALOP, A.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT MAHV, RANK () OVER (ORDER BY COUNT(MAMH) DESC) RANK_MH FROM KETQUATHI KQ 
	WHERE DIEM BETWEEN 9 AND 10
	GROUP BY KQ.MAHV
) A INNER JOIN HOCVIEN HV
ON A.MAHV = HV.MAHV
WHERE RANK_MH = 1
GROUP BY LEFT(A.MAHV, 3), A.MAHV, HO, TEN;

-- 28.	Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp.
SELECT HOCKY, NAM, MAGV, COUNT(MAMH) SOMH, COUNT(MALOP) SOLOP FROM GIANGDAY
GROUP BY HOCKY, NAM, MAGV;

-- 29.	Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất.
SELECT HOCKY, NAM, A.MAGV, HOTEN FROM (
	SELECT HOCKY, NAM, MAGV, RANK() OVER (PARTITION BY HOCKY, NAM ORDER BY COUNT(MAMH) DESC) RANK_SOMH FROM GIANGDAY
	GROUP BY HOCKY, NAM, MAGV
) A INNER JOIN GIAOVIEN GV 
ON A.MAGV = GV.MAGV
WHERE RANK_SOMH = 1;

-- 30.	Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất.
SELECT A.MAMH, TENMH FROM (
	SELECT MAMH, RANK() OVER (ORDER BY COUNT(MAHV) DESC) RANK_SOHV FROM KETQUATHI
	WHERE LANTHI = 1 AND KQUA = 'Khong Dat'
	GROUP BY MAMH
) A INNER JOIN MONHOC MH
ON A.MAMH = MH.MAMH
WHERE RANK_SOHV = 1;

-- 31.	Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).
SELECT A.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT MAHV, COUNT(KQUA) SODAT FROM KETQUATHI 
	WHERE LANTHI = 1 AND KQUA = 'Dat'
	GROUP BY MAHV
	INTERSECT
	SELECT MAHV, COUNT(MAMH) SOMH FROM KETQUATHI 
	WHERE LANTHI = 1
	GROUP BY MAHV
) A INNER JOIN HOCVIEN HV
ON A.MAHV = HV.MAHV;

-- 32.	* Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).
SELECT C.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT MAHV, COUNT(KQUA) SODAT FROM KETQUATHI A
	WHERE NOT EXISTS (
		SELECT 1 
		FROM KETQUATHI B 
		WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
	) AND KQUA = 'Dat'
	GROUP BY MAHV
	INTERSECT
	SELECT MAHV, COUNT(MAMH) SOMH FROM KETQUATHI 
	WHERE LANTHI = 1
	GROUP BY MAHV
) C INNER JOIN HOCVIEN HV
ON C.MAHV = HV.MAHV;

-- 33.	* Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi thứ 1).
SELECT A.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT MAHV, COUNT(KQUA) SODAT FROM KETQUATHI 
	WHERE LANTHI = 1 AND KQUA = 'Dat'
	GROUP BY MAHV
	INTERSECT
	SELECT MAHV, COUNT(MAMH) SOMH FROM KETQUATHI 
	WHERE LANTHI = 1
	GROUP BY MAHV
) A INNER JOIN HOCVIEN HV
ON A.MAHV = HV.MAHV;

-- 34.	* Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt  (chỉ xét lần thi sau cùng).
SELECT C.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT MAHV, COUNT(KQUA) SODAT FROM KETQUATHI A
	WHERE NOT EXISTS (
		SELECT 1 FROM KETQUATHI B 
		WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
	) AND KQUA = 'Dat'
	GROUP BY MAHV
	INTERSECT
	SELECT MAHV, COUNT(MAMH) SOMH FROM KETQUATHI 
	WHERE LANTHI = 1
	GROUP BY MAHV
) C INNER JOIN HOCVIEN HV
ON C.MAHV = HV.MAHV;

-- 35.	** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau cùng).
SELECT A.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT B.MAMH, MAHV, DIEM, DIEMMAX
	FROM KETQUATHI B INNER JOIN (
		SELECT MAMH, MAX(DIEM) DIEMMAX FROM KETQUATHI
		GROUP BY MAMH
	) C 
	ON B.MAMH = C.MAMH
	WHERE NOT EXISTS (
		SELECT 1 FROM KETQUATHI D 
		WHERE B.MAHV = D.MAHV AND B.MAMH = D.MAMH AND B.LANTHI < D.LANTHI
	) AND DIEM = DIEMMAX
) A INNER JOIN HOCVIEN HV
ON A.MAHV = HV.MAHV;