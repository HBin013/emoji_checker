
drop function if exists get_arrears_by_id;
drop procedure if exists update_reader_arrears_fn;
drop trigger if exists delete_book_trigger;
USE db;
##触发器
###删除图书时触发，如果booktable中已经没有对应的图书，则从booklist中删除对应的表项
CREATE TRIGGER delete_book_trigger

AFTER DELETE ON mylibrary_book_table
FOR EACH ROW
BEGIN
    DECLARE isbn_count INT;
    SELECT COUNT(*) INTO isbn_count FROM mylibrary_book_table WHERE isbn_id = OLD.isbn_id;
    IF isbn_count = 0 THEN
        DELETE FROM mylibrary_booklist_table WHERE isbn = OLD.isbn_id;
    END IF;
END;

##存储过程
###返回对应的可出库图书队列
USE db;
DELIMITER //
CREATE PROCEDURE get_book_cantakeoff(IN isbn_val VARCHAR(50), IN takeoff_place_val VARCHAR(50))
BEGIN
  IF takeoff_place_val = '图书流通室' THEN
      SELECT *
      FROM mylibrary_book_table
      WHERE isbn_id = isbn_val AND status = '未借出' AND storage_location = takeoff_place_val;
  ELSEIF takeoff_place_val = '图书阅览室' THEN
      SELECT *
      FROM mylibrary_book_table
      WHERE isbn_id = isbn_val AND status = '不外借' AND storage_location = takeoff_place_val;
  END IF;
END//
DELIMITER ;

###使用事务的过程 为读者缴费
####成功执行则返回当前读者欠费，不成功执行返回-1
USE db;
CREATE PROCEDURE update_reader_arrears_fn(
    reader_id_in INT,
    money_num FLOAT
)
BEGIN
    DECLARE arrears_of_reader FLOAT;
    DECLARE new_arrears FLOAT;
    DECLARE result FLOAT;
    START TRANSACTION;
    SELECT arrears INTO arrears_of_reader FROM mylibrary_reader_table WHERE reader_id = reader_id_in;
    SET arrears_of_reader = arrears_of_reader - money_num;
    ##为该读者缴费
    UPDATE mylibrary_reader_table SET arrears = arrears_of_reader WHERE reader_id = reader_id_in;
    SELECT arrears INTO new_arrears FROM mylibrary_reader_table WHERE reader_id = reader_id_in ;
    IF (new_arrears < 0) THEN
        ROLLBACK;
        SET result = -1;
        #返回值为-1表示还款数超过当前读者欠费，还款失败
    ELSE
        COMMIT;
        SET result=new_arrears;
        #返回读者当前欠费数，大于等于0
    END IF;
    SELECT result;
END;
USE db;
##函数
####返回读者欠费
CREATE FUNCTION get_arrears_by_id(reader_ID1 INT) RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
  DECLARE arrears_value DECIMAL(10,2);
  SELECT arrears INTO arrears_value FROM mylibrary_reader_table WHERE reader_id = reader_ID1;
  RETURN arrears_value;
END;