-- Câu hỏi SQL từ cơ bản đến nâng cao, bao gồm trigger
USE QUANLYCONGTY
-- Cơ bản:
--1. Liệt kê tất cả chuyên gia trong cơ sở dữ liệu.
SELECT *
FROM ChuyenGia
--2. Hiển thị tên và email của các chuyên gia nữ.
SELECT HoTen, Email
FROM ChuyenGia
WHERE GioiTinh = N'Nữ'
--3. Liệt kê các công ty có trên 100 nhân viên.
SELECT TenCongTy, SoNhanVien	
FROM CongTy
WHERE SoNhanVien > 100

--4. Hiển thị tên và ngày bắt đầu của các dự án trong năm 2023.
SELECT TenDuAn, NgayBatDau
FROM DuAn
WHERE YEAR(NgayBatDau) = 2023

--5

-- Trung cấp:
--6. Liệt kê tên chuyên gia và số lượng dự án họ tham gia.
SELECT CG.HoTen, COUNT(CG_DA.MaDuAn) 'SO LUONG DU AN THAM GIA'
FROM ChuyenGia CG JOIN ChuyenGia_DuAn CG_DA
ON CG.MaChuyenGia = CG_DA.MaChuyenGia
GROUP BY CG.MaChuyenGia, CG.HoTen

--7. Tìm các dự án có sự tham gia của chuyên gia có kỹ năng 'Python' cấp độ 4 trở lên.
SELECT CG_DA.MaDuAn
FROM ChuyenGia_DuAn CG_DA JOIN ChuyenGia CG
ON CG_DA.MaChuyenGia = CG.MaChuyenGia 
JOIN ChuyenGia_KyNang CG_KN
ON CG_KN.MaChuyenGia = CG.MaChuyenGia
JOIN KyNang KN
ON KN.MaKyNang = CG_KN.MaKyNang
WHERE KN.TenKyNang = 'Python' AND CG_KN.CapDo >=4

--8. Hiển thị tên công ty và số lượng dự án đang thực hiện.
SELECT TenCongTy, COUNT(DA.MaDuAn) 'SO LUONG DU AN THAM GIA'
FROM CongTy CT JOIN DuAn DA
ON CT.MaCongTy = DA.MaCongTy
GROUP BY CT.MaCongTy, TenCongTy

--9. Tìm chuyên gia có số năm kinh nghiệm cao nhất trong mỗi chuyên ngành.
SELECT CG1.ChuyenNganh, CG1.HoTen,CG1.NamKinhNghiem
FROM ChuyenGia CG1
WHERE CG1.MaChuyenGia IN (
    SELECT TOP 1 WITH TIES CG2.MaChuyenGia
    FROM ChuyenGia CG2
    WHERE CG1.ChuyenNganh = CG2.ChuyenNganh
    ORDER BY CG2.NamKinhNghiem DESC
)


--10. Liệt kê các cặp chuyên gia đã từng làm việc cùng nhau trong ít nhất một dự án.
SELECT DISTINCT CGD1.MaChuyenGia AS ChuyenGia1, CGD2.MaChuyenGia AS ChuyenGia2,DA.TenDuAn
FROM ChuyenGia_DuAn CGD1
JOIN ChuyenGia_DuAn CGD2 
ON CGD1.MaDuAn = CGD2.MaDuAn
JOIN DuAn DA 
ON CGD1.MaDuAn = DA.MaDuAn
WHERE CGD1.MaChuyenGia != CGD2.MaChuyenGia AND CGD1.MaChuyenGia < CGD2.MaChuyenGia

-- Nâng cao:
--11. Tính tổng thời gian (theo ngày) mà mỗi chuyên gia đã tham gia vào các dự án.
SELECT CGD.MaChuyenGia, CG.HoTen, SUM(DATEDIFF(DAY, CGD.NgayThamGia, DA.NgayKetThuc)) AS TongThoiGianThamGia
FROM ChuyenGia_DuAn CGD
JOIN DuAn DA ON CGD.MaDuAn = DA.MaDuAn
JOIN ChuyenGia CG ON CGD.MaChuyenGia = CG.MaChuyenGia
GROUP BY CGD.MaChuyenGia, CG.HoTen

--12. Tìm các công ty có tỷ lệ dự án hoàn thành cao nhất (trên 90%).
SELECT TOP 1 WITH TIES 
    CT.TenCongTy,
    1.0 * SUM(CASE WHEN DA.TrangThai = N'Hoàn Thành' THEN 1 ELSE 0 END) / COUNT(*) AS 'TI LE TRUNG BINH'
FROM CongTy CT 
JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
GROUP BY CT.MaCongTy, CT.TenCongTy
HAVING SUM(CASE WHEN DA.TrangThai = N'Hoàn Thành' THEN 1 ELSE 0 END) / COUNT(*) >= 0.9
ORDER BY SUM(CASE WHEN DA.TrangThai = N'Hoàn Thành' THEN 1 ELSE 0 END) / COUNT(*) DESC;

--13. Liệt kê top 3 kỹ năng được yêu cầu nhiều nhất trong các dự án.
SELECT TOP 3 KN.MaKyNang,KN.TenKyNang
FROM KyNang KN JOIN ChuyenGia_KyNang CG_KN ON KN.MaKyNang = CG_KN.MaKyNang
JOIN ChuyenGia CG ON CG.MaChuyenGia = CG_KN.MaChuyenGia
JOIN ChuyenGia_DuAn CG_DA ON CG_DA.MaChuyenGia = CG.MaChuyenGia
GROUP BY KN.MaKyNang, KN.TenKyNang
ORDER BY COUNT(DISTINCT CG_DA.MaDuAn) DESC

--14. Tính lương trung bình của chuyên gia theo từng cấp độ kinh nghiệm (Junior: 0-2 năm, Middle: 3-5 năm, Senior: >5 năm).



--15. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT DA.MaDuAn, DA.TenDuAn
FROM DuAn DA
WHERE NOT EXISTS (
    SELECT CG.ChuyenNganh
    FROM ChuyenGia CG
    WHERE NOT EXISTS (
        SELECT *
        FROM ChuyenGia_DuAn CG_DA
        WHERE CG_DA.MaChuyenGia = CG.MaChuyenGia
        AND CG_DA.MaDuAn = DA.MaDuAn
    )
);

-- Trigger:
--16. Tạo một trigger để tự động cập nhật số lượng dự án của công ty khi thêm hoặc xóa dự án.
ALTER TABLE CongTy
ADD SoLuongDuAn INT DEFAULT 0;

ALTER TRIGGER trg_UpdateProjectCount
ON DuAn
AFTER INSERT, DELETE
AS
BEGIN
	
    UPDATE CongTy
    SET SoLuongDuAn = (
        SELECT COUNT(*)
        FROM DuAn
        WHERE DuAn.MaCongTy = CongTy.MaCongTy
    )
    WHERE CongTy.MaCongTy IN (
        SELECT MaCongTy FROM INSERTED
        UNION
        SELECT MaCongTy FROM DELETED
    );
END;


--17. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE TRIGGER trg_LogChangeChuyenGia
ON ChuyenGia
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Action NVARCHAR(50);
    DECLARE @Now DATETIME = GETDATE();

    IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
        SET @Action = 'Update';
    ELSE IF EXISTS (SELECT * FROM INSERTED)
        SET @Action = 'Insert';
    ELSE IF EXISTS (SELECT * FROM DELETED)
        SET @Action = 'Delete';

    INSERT INTO LogChuyenGia (Action, ThoiGian)
    VALUES (@Action, @Now);
END;


--18. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
ALTER TRIGGER trg_LimitChuyenGiaProjects
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
	DECLARE @MCG INT
	SELECT @MCG = MaChuyenGia
	FROM inserted
    IF @MCG IN (
	   SELECT MaChuyenGia
        FROM ChuyenGia_DuAn
        GROUP BY MaChuyenGia
		HAVING COUNT(MaDuAn) > 4
		)
    BEGIN
        RAISERROR ('Một chuyên gia không được tham gia quá 5 dự án.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
SELECT * 
FROM ChuyenGia_DuAn
INSERT INTO ChuyenGia_DuAn (MaChuyenGia, MaDuAn, VaiTro, NgayThamGia)
VALUES 
(3, 1, N'Trưởng nhóm phát triển', '2023-01-01'),
(3, 2, N'Trưởng nhóm phát triển', '2023-01-01'),
(3, 3, N'Trưởng nhóm phát triển', '2023-01-01')
--19. Tạo một trigger để tự động cập nhật trạng thái của dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc.


--20. Tạo một trigger để tự động tính toán và cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.