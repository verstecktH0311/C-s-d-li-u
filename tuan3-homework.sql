USE QUANLYCONGTY
SET DATEFORMAT DMY;

-- 8. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1.
SELECT K.TenKyNang, CGK.CapDo
FROM ChuyenGia_KyNang CGK
JOIN KyNang K ON CGK.MaKyNang = K.MaKyNang
WHERE CGK.MaChuyenGia = 1;

-- 9. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2.
SELECT CG.HoTen
FROM ChuyenGia CG
JOIN ChuyenGia_DuAn CGD ON CG.MaChuyenGia = CGD.MaChuyenGia
WHERE CGD.MaDuAn = 2;

-- 10. Hiển thị tên công ty và tên dự án của tất cả các dự án.
SELECT CT.TenCongTy, DA.TenDuAn
FROM CongTy CT
JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy;

-- 11. Đếm số lượng chuyên gia trong mỗi chuyên ngành.
SELECT ChuyenNganh, COUNT(*) AS SoLuongChuyenGia
FROM ChuyenGia
GROUP BY ChuyenNganh;

-- 12. Tìm chuyên gia có số năm kinh nghiệm cao nhất.
SELECT TOP 1 *
FROM ChuyenGia
ORDER BY NamKinhNghiem DESC;

-- 13. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia.
SELECT CG.HoTen, COUNT(CGD.MaDuAn) AS SoLuongDuAn
FROM ChuyenGia CG
LEFT JOIN ChuyenGia_DuAn CGD ON CG.MaChuyenGia = CGD.MaChuyenGia
GROUP BY CG.HoTen;

-- 14. Hiển thị tên công ty và số lượng dự án của mỗi công ty.
SELECT CT.TenCongTy, COUNT(DA.MaDuAn) AS SoLuongDuAn
FROM CongTy CT
LEFT JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
GROUP BY CT.TenCongTy;

-- 15. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất.
SELECT K.TenKyNang
FROM KyNang K
JOIN ChuyenGia_KyNang CGK ON K.MaKyNang = CGK.MaKyNang
GROUP BY K.TenKyNang
HAVING COUNT(CGK.MaChuyenGia) = (
    SELECT MAX(SoLuongChuyenGia)
    FROM (
        SELECT COUNT(CGK.MaChuyenGia) AS SoLuongChuyenGia
        FROM ChuyenGia_KyNang CGK
        GROUP BY CGK.MaKyNang
    ) AS SkillCounts
);

-- 16. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên.
SELECT CG.HoTen
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGK ON CG.MaChuyenGia = CGK.MaChuyenGia
JOIN KyNang K ON CGK.MaKyNang = K.MaKyNang
WHERE K.TenKyNang = 'Python' AND CGK.CapDo >= 4;

-- 17. Tìm dự án có nhiều chuyên gia tham gia nhất.
SELECT DA.TenDuAn
FROM DuAn DA
JOIN ChuyenGia_DuAn CGD ON DA.MaDuAn = CGD.MaDuAn
GROUP BY DA.TenDuAn
HAVING COUNT(CGD.MaChuyenGia) = (
    SELECT MAX(SoLuongChuyenGia)
    FROM (
        SELECT COUNT(CGD.MaChuyenGia) AS SoLuongChuyenGia
        FROM ChuyenGia_DuAn CGD
        GROUP BY CGD.MaDuAn
    ) AS ProjectCounts
);

-- 18. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia.
SELECT CG.HoTen, COUNT(CGK.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia CG
LEFT JOIN ChuyenGia_KyNang CGK ON CG.MaChuyenGia = CGK.MaChuyenGia
GROUP BY CG.HoTen;

-- 19. Tìm các cặp chuyên gia làm việc cùng dự án.
SELECT CG1.HoTen AS ChuyenGia1, CG2.HoTen AS ChuyenGia2, CGD1.MaDuAn
FROM ChuyenGia_DuAn CGD1
JOIN ChuyenGia_DuAn CGD2 ON CGD1.MaDuAn = CGD2.MaDuAn
JOIN ChuyenGia CG1 ON CGD1.MaChuyenGia = CG1.MaChuyenGia
JOIN ChuyenGia CG2 ON CGD2.MaChuyenGia = CG2.MaChuyenGia
WHERE CG1.MaChuyenGia <> CG2.MaChuyenGia AND CG1.MaChuyenGia < CG2.MaChuyenGia
ORDER BY CGD1.MaDuAn;

-- 20. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ.
SELECT CG.HoTen, COUNT(CGK.CapDo) AS SoLuongKyNangCapDo5
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGK ON CG.MaChuyenGia = CGK.MaChuyenGia
WHERE CGK.CapDo = 5
GROUP BY CG.HoTen;

-- 21. Tìm các công ty không có dự án nào.
SELECT CT.TenCongTy
FROM CongTy CT
LEFT JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
WHERE DA.MaDuAn IS NULL;

-- 22. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả chuyên gia không tham gia dự án nào.
SELECT CG.HoTen, DA.TenDuAn
FROM ChuyenGia CG
LEFT JOIN ChuyenGia_DuAn CGD ON CG.MaChuyenGia = CGD.MaChuyenGia
LEFT JOIN DuAn DA ON CGD.MaDuAn = DA.MaDuAn;

-- 23. Tìm các chuyên gia có ít nhất 3 kỹ năng.
SELECT CG.HoTen
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGK ON CG.MaChuyenGia = CGK.MaChuyenGia
GROUP BY CG.HoTen
HAVING COUNT(CGK.MaKyNang) >= 3;

-- 24. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó.
SELECT CT.TenCongTy, SUM(CG.NamKinhNghiem) AS TongNamKinhNghiem
FROM CongTy CT
JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
JOIN ChuyenGia_DuAn CGD ON DA.MaDuAn = CGD.MaDuAn
JOIN ChuyenGia CG ON CGD.MaChuyenGia = CG.MaChuyenGia
GROUP BY CT.TenCongTy;

-- 25. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python'.
SELECT CG.HoTen
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGK1 ON CG.MaChuyenGia = CGK1.MaChuyenGia
WHERE CGK1.MaKyNang = (SELECT MaKyNang FROM KyNang WHERE TenKyNang = 'Java')
AND CG.MaChuyenGia NOT IN (
    SELECT CGK2.MaChuyenGia
    FROM ChuyenGia_KyNang CGK2
    WHERE CGK2.MaKyNang = (SELECT MaKyNang FROM KyNang WHERE TenKyNang = 'Python')
);

-- 76. Tìm chuyên gia có số lượng kỹ năng nhiều nhất.
SELECT CG.HoTen
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGK ON CG.MaChuyenGia = CGK.MaChuyenGia
GROUP BY CG.MaChuyenGia, CG.HoTen
HAVING COUNT(CGK.MaKyNang) = (
    SELECT MAX(SoLuongKyNang)
    FROM (
        SELECT COUNT(CGK.MaKyNang) AS SoLuongKyNang
        FROM ChuyenGia_KyNang CGK
        GROUP BY CGK.MaChuyenGia
    ) AS SkillCounts
);

-- 77. Liệt kê các cặp chuyên gia có cùng chuyên ngành.
SELECT CG1.HoTen AS ChuyenGia1, CG2.HoTen AS ChuyenGia2
FROM ChuyenGia CG1
JOIN ChuyenGia CG2 ON CG1.ChuyenNganh = CG2.ChuyenNganh
WHERE CG1.MaChuyenGia <> CG2.MaChuyenGia;

-- 78. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất.
SELECT TOP 1 CT.TenCongTy
FROM CongTy CT
JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
JOIN ChuyenGia_DuAn CGD ON DA.MaDuAn = CGD.MaDuAn
JOIN ChuyenGia CG ON CGD.MaChuyenGia = CG.MaChuyenGia
GROUP BY CT.TenCongTy
ORDER BY SUM(CG.NamKinhNghiem) DESC;

-- 79. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia.
SELECT KN.TenKyNang
FROM KyNang KN
JOIN ChuyenGia_KyNang CGKN ON KN.MaKyNang = CGKN.MaKyNang
GROUP BY KN.TenKyNang
HAVING COUNT(DISTINCT CGKN.MaChuyenGia) = (SELECT COUNT(*) FROM ChuyenGia);