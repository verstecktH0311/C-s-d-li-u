SET DATEFORMAT DMY; 
USE QUANLYCONGTY;

-- 76. Liệt kê top 3 chuyên gia có nhiều kỹ năng nhất và số lượng kỹ năng của họ.
WITH RankedChuyenGia AS (
    SELECT C.HoTen, COUNT(CKN.MaKyNang) AS SoLuongKyNang,
           ROW_NUMBER() OVER (ORDER BY COUNT(CKN.MaKyNang) DESC) AS RowNum
    FROM ChuyenGia C
    JOIN ChuyenGia_KyNang CKN ON C.MaChuyenGia = CKN.MaChuyenGia
    GROUP BY C.MaChuyenGia, C.HoTen
)
SELECT HoTen, SoLuongKyNang
FROM RankedChuyenGia
WHERE RowNum <= 3;

-- 77. Tìm các cặp chuyên gia có cùng chuyên ngành và số năm kinh nghiệm chênh lệch không quá 2 năm.
SELECT C1.HoTen AS ChuyenGia1, C2.HoTen AS ChuyenGia2, C1.ChuyenNganh
FROM ChuyenGia C1
JOIN ChuyenGia C2 ON C1.MaChuyenGia < C2.MaChuyenGia
WHERE C1.ChuyenNganh = C2.ChuyenNganh
  AND ABS(C1.NamKinhNghiem - C2.NamKinhNghiem) <= 2;

-- 78. Hiển thị tên công ty, số lượng dự án và tổng số năm kinh nghiệm của các chuyên gia tham gia dự án của công ty đó.
SELECT CT.TenCongTy, COUNT(D.MaDuAn) AS SoLuongDuAn, SUM(C.NamKinhNghiem) AS TongNamKinhNghiem
FROM CongTy CT
JOIN DuAn D ON CT.MaCongTy = D.MaCongTy
JOIN ChuyenGia_DuAn CG_DA ON D.MaDuAn = CG_DA.MaDuAn
JOIN ChuyenGia C ON CG_DA.MaChuyenGia = C.MaChuyenGia
GROUP BY CT.MaCongTy, CT.TenCongTy;

-- 79. Tìm các chuyên gia có ít nhất một kỹ năng cấp độ 5 nhưng không có kỹ năng nào dưới cấp độ 3.
SELECT C.HoTen
FROM ChuyenGia C
JOIN ChuyenGia_KyNang CKN ON C.MaChuyenGia = CKN.MaChuyenGia
GROUP BY C.MaChuyenGia, C.HoTen
HAVING MAX(CKN.CapDo) = 5 AND MIN(CKN.CapDo) >= 3;

-- 80. Liệt kê các chuyên gia và số lượng dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào.
SELECT C.HoTen, COUNT(CGA.MaDuAn) AS SoLuongDuAn
FROM ChuyenGia C
LEFT JOIN ChuyenGia_DuAn CGA ON C.MaChuyenGia = CGA.MaChuyenGia
GROUP BY C.MaChuyenGia, C.HoTen;

-- 81*. Tìm chuyên gia có kỹ năng ở cấp độ cao nhất trong mỗi loại kỹ năng.
WITH MaxCapDo AS (
    SELECT MaKyNang, MAX(CapDo) AS MaxCapDo
    FROM ChuyenGia_KyNang
    GROUP BY MaKyNang
)
SELECT C.HoTen, K.TenKyNang, CKN.CapDo
FROM ChuyenGia C
JOIN ChuyenGia_KyNang CKN ON C.MaChuyenGia = CKN.MaChuyenGia
JOIN KyNang K ON CKN.MaKyNang = K.MaKyNang
JOIN MaxCapDo MCD ON CKN.MaKyNang = MCD.MaKyNang AND CKN.CapDo = MCD.MaxCapDo;

-- 82. Tính tỷ lệ phần trăm của mỗi chuyên ngành trong tổng số chuyên gia.
SELECT ChuyenNganh, 
       COUNT(MaChuyenGia) * 100.0 / (SELECT COUNT(*) FROM ChuyenGia) AS TyLePhanTram
FROM ChuyenGia
GROUP BY ChuyenNganh;

-- 83. Tìm các cặp kỹ năng thường xuất hiện cùng nhau nhất trong hồ sơ của các chuyên gia.
WITH CTE AS (
    SELECT CKN1.MaKyNang AS KyNang1, CKN2.MaKyNang AS KyNang2, 
           COUNT(*) AS SoLanXuatHien
    FROM ChuyenGia_KyNang CKN1
    JOIN ChuyenGia_KyNang CKN2 ON CKN1.MaChuyenGia = CKN2.MaChuyenGia 
                               AND CKN1.MaKyNang < CKN2.MaKyNang
    GROUP BY CKN1.MaKyNang, CKN2.MaKyNang
)
, RankedCTE AS (
    SELECT KyNang1, KyNang2, SoLanXuatHien,
           ROW_NUMBER() OVER (ORDER BY SoLanXuatHien DESC) AS RowNum
    FROM CTE
)
SELECT KyNang1, KyNang2, SoLanXuatHien
FROM RankedCTE
WHERE RowNum = 1;

-- 84. Tính số ngày trung bình giữa ngày bắt đầu và ngày kết thúc của các dự án cho mỗi công ty.
SELECT CT.TenCongTy,
       AVG(DATEDIFF(DAY, DA.NgayBatDau, DA.NgayKetThuc)) AS SoNgayTrungBinh
FROM CongTy CT
JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
GROUP BY CT.TenCongTy;

-- 85*. Tìm chuyên gia có sự kết hợp độc đáo nhất của các kỹ năng (kỹ năng mà chỉ họ có).
SELECT C.HoTen
FROM ChuyenGia C
WHERE NOT EXISTS (
    SELECT 1
    FROM ChuyenGia_KyNang CKN1
    WHERE CKN1.MaChuyenGia != C.MaChuyenGia
    AND NOT EXISTS (
        SELECT 1
        FROM ChuyenGia_KyNang CKN2
        WHERE CKN2.MaChuyenGia = C.MaChuyenGia AND CKN2.MaKyNang = CKN1.MaKyNang
    )
);

-- 86*. Tạo một bảng xếp hạng các chuyên gia dựa trên số lượng dự án và tổng cấp độ kỹ năng.
SELECT C.HoTen, COUNT(CGA.MaDuAn) AS SoLuongDuAn, SUM(CKN.CapDo) AS TongCapDoKyNang
FROM ChuyenGia C
JOIN ChuyenGia_DuAn CGA ON C.MaChuyenGia = CGA.MaChuyenGia
JOIN ChuyenGia_KyNang CKN ON C.MaChuyenGia = CKN.MaChuyenGia
GROUP BY C.MaChuyenGia, C.HoTen
ORDER BY SoLuongDuAn DESC, TongCapDoKyNang DESC;

-- 87. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT D.TenDuAn
FROM DuAn D
JOIN ChuyenGia_DuAn CG_DA ON D.MaDuAn = CG_DA.MaDuAn
JOIN ChuyenGia C ON CG_DA.MaChuyenGia = C.MaChuyenGia
GROUP BY D.MaDuAn, D.TenDuAn
HAVING COUNT(DISTINCT C.ChuyenNganh) = (SELECT COUNT(DISTINCT ChuyenNganh) FROM ChuyenGia);

-- 88. Tính tỷ lệ thành công của mỗi công ty dựa trên số dự án hoàn thành so với tổng số dự án.
SELECT CT.TenCongTy,
       SUM(CASE WHEN D.TrangThai = 'Hoàn thành' THEN 1 ELSE 0 END) * 100.0 / COUNT(D.MaDuAn) AS TyLeThanhCong
FROM CongTy CT
JOIN DuAn D ON CT.MaCongTy = D.MaCongTy
GROUP BY CT.MaCongTy, CT.TenCongTy;

-- 89. Tìm các chuyên gia có kỹ năng "bù trừ" nhau (một người giỏi kỹ năng A nhưng yếu kỹ năng B, người kia ngược lại).
SELECT DISTINCT CG1.HoTen AS ChuyenGia1, CG2.HoTen AS ChuyenGia2,
       K1.TenKyNang AS KyNangA, K2.TenKyNang AS KyNangB
FROM ChuyenGia_KyNang CKN1
JOIN ChuyenGia_KyNang CKN2 
    ON CKN1.MaChuyenGia <> CKN2.MaChuyenGia  -- Chọn chuyên gia khác nhau
JOIN KyNang K1 ON CKN1.MaKyNang = K1.MaKyNang
JOIN KyNang K2 ON CKN2.MaKyNang = K2.MaKyNang
JOIN ChuyenGia CG1 ON CKN1.MaChuyenGia = CG1.MaChuyenGia
JOIN ChuyenGia CG2 ON CKN2.MaChuyenGia = CG2.MaChuyenGia
WHERE CKN1.MaKyNang <> CKN2.MaKyNang  -- Không cùng một kỹ năng
  AND ((CKN1.CapDo > CKN2.CapDo AND CKN1.MaKyNang = K1.MaKyNang AND CKN2.MaKyNang = K2.MaKyNang) -- Chuyên gia 1 giỏi kỹ năng A nhưng yếu kỹ năng B
       OR (CKN1.CapDo < CKN2.CapDo AND CKN1.MaKyNang = K2.MaKyNang AND CKN2.MaKyNang = K1.MaKyNang)) -- Chuyên gia 2 giỏi kỹ năng B nhưng yếu kỹ năng A
ORDER BY CG1.HoTen, CG2.HoTen;



