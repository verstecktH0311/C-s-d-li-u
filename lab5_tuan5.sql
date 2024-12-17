USE QUANLYBANHANG
--QUAN LY BAN HANG
--11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK) 
CREATE TRIGGER trg_ins_Hd 
ON HOADON
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @NgayHD smalldatetime, @MaKH char(4), @NgayDK smalldatetime
	SELECT @NgayHD = NGHD, @MaKH = MAKH
	FROM INSERTED
	SELECT @NgayDK = NGDK
	FROM KHACHHANG
	WHERE MAKH = @MaKH
	IF(@NgayHD < @NgayDK)
	BEGIN 
		PRINT 'LOI: NGAY HOA DON KHONG HOP LE!'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'THEM MOT HOA DON THANH CONG!'
    END
END

CREATE TRIGGER trg_in_Kh
ON KHACHHANG
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MAKH char(4), @NGDK smalldatetime, @NGHD smalldatetime
	SELECT @MAKH = MAKH, @NGDK = NGDK  
	FROM INSERTED
	SELECT @NGHD = NGHD
	FROM HOADON
	IF (@NGHD > @NGDK)
	BEGIN
		PRINT 'DA THEM MOT DONG DU LIEU'
	END
	ELSE
	BEGIN 
		PRINT 'LOI: NGAY HOA DON KHONG HOP LE!'
		ROLLBACK TRANSACTION
	END
END

--12. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm
CREATE TRIGGER trg_ins_hd1
ON HOADON
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @NGHD smalldatetime, @NGVL smalldatetime, @MANV char(4)
	SELECT @MANV = MANV, @NGHD = NGHD
	FROM INSERTED 
	SELECT @NGVL = NGVL
	FROM NHANVIEN
	WHERE MANV = @MANV
	IF(@NGHD > @NGVL)
	BEGIN 
		PRINT 'DA THEM MOT DONG DU LIEU'
		
	END
	ELSE 
	BEGIN
		PRINT 'LOI: NGAY HOA DON KHONG HOP LE!'
		ROLLBACK TRANSACTION
	END
END
	
--13. Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó.
CREATE TRIGGER trg_UpdateTriGia
ON CTHD
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
   
    UPDATE HOADON
    SET TRIGIA = (
        SELECT SUM(C.SL * S.GIA)
        FROM CTHD C
        JOIN SANPHAM S ON C.MASP = S.MASP
        WHERE C.SOHD = HOADON.SOHD
    )
    WHERE SOHD IN (
      
        SELECT DISTINCT SOHD FROM INSERTED
        UNION
        SELECT DISTINCT SOHD FROM DELETED
    );
END;

--14. Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã
CREATE TRIGGER TRG_UPDATE_DS
ON HOADON
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
	UPDATE KHACHHANG 
	SET DOANHSO = (
		SELECT SUM(TRIGIA)
		FROM HOADON HD
		WHERE KHACHHANG.MAKH = HD.MAKH

	)
	WHERE MAKH IN (
		SELECT DISTINCT MAKH FROM INSERTED
        UNION
        SELECT DISTINCT MAKH FROM DELETED
	)
END

USE QUANLYGIAOVU
--QUAN LY GIAO VU 
--9. Lớp trưởng của một lớp phải là học viên của lớp đó
CREATE TRIGGER HV_UPDATE_MALOP
ON HOCVIEN
AFTER UPDATE
AS
BEGIN
    -- Kiểm tra nếu lớp trưởng của một lớp không thuộc lớp đó
    IF EXISTS (
        SELECT 1
        FROM inserted I
        JOIN LOP L ON I.MAHV = L.TRGLOP
        WHERE I.MALOP != L.MALOP
    )
    BEGIN
        PRINT 'LOI: Lop truong cua mot lop phai la hoc vien lop do';
        ROLLBACK TRANSACTION;
    END;
END;

CREATE TRIGGER LOP_VALIDATE_TRGLOP
ON LOP
AFTER UPDATE
AS
BEGIN
    -- Kiểm tra nếu lớp trưởng không thuộc lớp
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        LEFT JOIN HOCVIEN H
        ON I.TRGLOP = H.MAHV AND I.MALOP = H.MALOP
        WHERE I.TRGLOP IS NOT NULL AND H.MAHV IS NULL
    )
    BEGIN
        PRINT 'LOI: Lop truong phai la mot hoc vien thuoc lop';
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
--10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”
CREATE TRIGGER TRG_VALIDATE_TRGKHOA
ON KHOA
AFTER UPDATE, INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        LEFT JOIN GIAOVIEN GV
        ON I.TRGKHOA = GV.MAGV AND I.MAKHOA = GV.MAKHOA
        WHERE I.TRGKHOA IS NOT NULL 
        AND (GV.MAGV IS NULL OR GV.HOCVI NOT IN ('TS', 'PTS'))
    )
    BEGIN
        PRINT 'LOI: Truong khoa phai la giao vien thuoc khoa va co hoc vi TS hoac PTS';
        ROLLBACK TRANSACTION;
    END;
END;

--15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này
CREATE TRIGGER TRG_VALIDATE_KETQUATHI
ON KETQUATHI
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        LEFT JOIN GIANGDAY GD
        ON I.MAMH = GD.MAMH AND GD.MALOP = (SELECT MALOP FROM HOCVIEN WHERE MAHV = I.MAHV)
        WHERE GD.DENNGAY > I.NGTHI
    )
    BEGIN
        PRINT 'LOI: Hoc vien chi duoc thi sau khi lop da hoc xong mon hoc';
        ROLLBACK TRANSACTION;
    END;
END;

--16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn
CREATE TRIGGER TRG_VALIDATE_GIANGDAY
ON GIANGDAY
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        WHERE (
            SELECT COUNT(*)
            FROM GIANGDAY
            WHERE MALOP = I.MALOP AND HOCKY = I.HOCKY AND NAM = I.NAM
        ) > 3
    )
    BEGIN
        PRINT 'LOI: Moi hoc ky cua mot nam hoc, mot lop chi duoc hoc toi da 3 mon';
        ROLLBACK TRANSACTION;
    END;
END;

--17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó
CREATE TRIGGER TRG_UPDATE_SISO
ON HOCVIEN
AFTER INSERT, DELETE
AS
BEGIN
    UPDATE LOP
    SET SISO = (SELECT COUNT(*) FROM HOCVIEN WHERE MALOP = LOP.MALOP);
END;

--18. Trong quan hệ DIEUKIEN, không được tồn tại các cặp quan hệ không hợp lệ
CREATE TRIGGER TRG_VALIDATE_DIEUKIEN
ON DIEUKIEN
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        WHERE I.MAMH = I.MAMH_TRUOC
           OR EXISTS (
               SELECT 1
               FROM DIEUKIEN D
               WHERE D.MAMH = I.MAMH_TRUOC AND D.MAMH_TRUOC = I.MAMH
           )
    )
    BEGIN
        PRINT 'LOI: Gia tri cua MAMH va MAMH_TRUOC khong duoc giong nhau hoac co quan he xung dot';
        ROLLBACK TRANSACTION;
    END;
END;

--19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau
CREATE TRIGGER TRG_VALIDATE_MUCLUONG
ON GIAOVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM GIAOVIEN G1
        JOIN GIAOVIEN G2
        ON G1.HOCVI = G2.HOCVI AND G1.HOCHAM = G2.HOCHAM AND G1.HESO = G2.HESO
        WHERE G1.MUCLUONG != G2.MUCLUONG
    )
    BEGIN
        PRINT 'LOI: Cac giao vien co cung hoc vi, hoc ham, he so luong thi muc luong phai bang nhau';
        ROLLBACK TRANSACTION;
    END;
END;

--20. Học viên chỉ được thi lại (lần thi > 1) khi điểm lần thi trước dưới 5
CREATE TRIGGER TRG_VALIDATE_LANTHI
ON KETQUATHI
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN KETQUATHI K
        ON I.MAHV = K.MAHV AND I.MAMH = K.MAMH AND I.LANTHI > K.LANTHI
        WHERE K.DIEM >= 5
    )
    BEGIN
        PRINT 'LOI: Hoc vien chi duoc thi lai khi diem lan truoc duoi 5';
        ROLLBACK TRANSACTION;
    END;
END;
--21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước
CREATE TRIGGER TRG_VALIDATE_NGTHI
ON KETQUATHI
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN KETQUATHI K
        ON I.MAHV = K.MAHV AND I.MAMH = K.MAMH AND I.LANTHI > K.LANTHI
        WHERE I.NGTHI <= K.NGTHI
    )
    BEGIN
        PRINT 'LOI: Ngay thi cua lan sau phai lon hon ngay thi cua lan truoc';
        ROLLBACK TRANSACTION;
    END;
END;

--22. Phân công giảng dạy phải xét đến thứ tự môn học trước sau
CREATE TRIGGER TRG_VALIDATE_GIANGDAY_DIEUKIEN
ON GIANGDAY
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN DIEUKIEN D
        ON I.MAMH = D.MAMH
        WHERE EXISTS (
            SELECT 1
            FROM GIANGDAY GD
            WHERE GD.MALOP = I.MALOP AND GD.MAMH = D.MAMH_TRUOC AND GD.DENNGAY > I.TUNGAY
        )
    )
    BEGIN
        PRINT 'LOI: Phai hoc xong mon truoc khi phan cong giang day mon sau';
        ROLLBACK TRANSACTION;
    END;
END;

--23. Giáo viên chỉ được phân công dạy môn học thuộc khoa mình
CREATE TRIGGER TRG_VALIDATE_GIANGDAY_GIAOVIEN
ON GIANGDAY
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN MONHOC MH
        ON I.MAMH = MH.MAMH
        JOIN GIAOVIEN GV
        ON I.MAGV = GV.MAGV
        WHERE MH.MAKHOA != GV.MAKHOA
    )
    BEGIN
        PRINT 'LOI: Giao vien chi duoc day mon hoc thuoc khoa minh phu trach';
        ROLLBACK TRANSACTION;
    END;
END;








