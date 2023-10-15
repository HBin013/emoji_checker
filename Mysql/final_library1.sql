drop table if exists auth_group_permissions;
drop table if exists auth_user_groups;
drop table if exists auth_group;
drop table if exists auth_user_user_permissions;
drop table if exists auth_permission;
drop table if exists django_admin_log;
drop table if exists auth_user;
drop table if exists django_content_type;
drop table if exists django_migrations;
drop table if exists django_session;
drop table if exists mylibrary_borrow_table;
drop table if exists mylibrary_recommend_table;
drop table if exists mylibrary_reservation_table;
drop table if exists mylibrary_book_table;
drop table if exists mylibrary_booklist_table;
drop table if exists mylibrary_librarian_table;
drop table if exists mylibrary_reader_table;
drop procedure if exists get_book_cantakeoff;
drop function if exists get_recommendation;
drop procedure if exists update_reader_arrears_fn;
create table auth_group
(
    id   int auto_increment
        primary key,
    name varchar(150) not null,
    constraint name
        unique (name)
);
create table auth_user
(
    id           int auto_increment
        primary key,
    password     varchar(128) not null,
    last_login   datetime(6)  null,
    is_superuser tinyint(1)   not null,
    username     varchar(150) not null,
    first_name   varchar(150) not null,
    last_name    varchar(150) not null,
    email        varchar(254) not null,
    is_staff     tinyint(1)   not null,
    is_active    tinyint(1)   not null,
    date_joined  datetime(6)  not null,
    constraint username
        unique (username)
);
create table auth_user_groups
(
    id       int auto_increment
        primary key,
    user_id  int not null,
    group_id int not null,
    constraint auth_user_groups_user_id_group_id_94350c0c_uniq
        unique (user_id, group_id),
    constraint auth_user_groups_group_id_97559544_fk_auth_group_id
        foreign key (group_id) references auth_group (id),
    constraint auth_user_groups_user_id_6a12ed8b_fk_auth_user_id
        foreign key (user_id) references auth_user (id)
);

create table django_content_type
(
    id        int auto_increment
        primary key,
    app_label varchar(100) not null,
    model     varchar(100) not null,
    constraint django_content_type_app_label_model_76bd3d3b_uniq
        unique (app_label, model)
);

create table auth_permission
(
    id              int auto_increment
        primary key,
    name            varchar(255) not null,
    content_type_id int          not null,
    codename        varchar(100) not null,
    constraint auth_permission_content_type_id_codename_01ab375a_uniq
        unique (content_type_id, codename),
    constraint auth_permission_content_type_id_2f476e4b_fk_django_co
        foreign key (content_type_id) references django_content_type (id)
);

create table auth_group_permissions
(
    id            int auto_increment
        primary key,
    group_id      int not null,
    permission_id int not null,
    constraint auth_group_permissions_group_id_permission_id_0cd325b0_uniq
        unique (group_id, permission_id),
    constraint auth_group_permissio_permission_id_84c5c92e_fk_auth_perm
        foreign key (permission_id) references auth_permission (id),
    constraint auth_group_permissions_group_id_b120cbf9_fk_auth_group_id
        foreign key (group_id) references auth_group (id)
);

create table auth_user_user_permissions
(
    id            int auto_increment
        primary key,
    user_id       int not null,
    permission_id int not null,
    constraint auth_user_user_permissions_user_id_permission_id_14a6b632_uniq
        unique (user_id, permission_id),
    constraint auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm
        foreign key (permission_id) references auth_permission (id),
    constraint auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id
        foreign key (user_id) references auth_user (id)
);

create table django_admin_log
(
    id              int auto_increment
        primary key,
    action_time     datetime(6)       not null,
    object_id       longtext          null,
    object_repr     varchar(200)      not null,
    action_flag     smallint unsigned not null,
    change_message  longtext          not null,
    content_type_id int               null,
    user_id         int               not null,
    constraint django_admin_log_content_type_id_c4bce8eb_fk_django_co
        foreign key (content_type_id) references django_content_type (id),
    constraint django_admin_log_user_id_c564eba6_fk_auth_user_id
        foreign key (user_id) references auth_user (id),
    check (`action_flag` >= 0)
);

create table django_migrations
(
    id      int auto_increment
        primary key,
    app     varchar(255) not null,
    name    varchar(255) not null,
    applied datetime(6)  not null
);

create table django_session
(
    session_key  varchar(40) not null
        primary key,
    session_data longtext    not null,
    expire_date  datetime(6) not null
);

create index django_session_expire_date_a5c62663
    on django_session (expire_date);

create table mylibrary_librarian_table
(
    staff_id varchar(20)  not null
        primary key,
    password varchar(256) not null,
    name     varchar(10)  not null
);

create table mylibrary_booklist_table
(
    isbn         varchar(50)  not null
        primary key,
    book_name    varchar(50)  not null,
    author       varchar(50)  not null,
    publisher    varchar(50)  not null,
    publish_date datetime(6)  not null,
    image        varchar(100) null,
    pdf          varchar(100) null,
    vedio        varchar(100) null,
    operator_id  varchar(20)  not null,
    constraint myLibrary_booklist_t_operator_id_e2727384_fk_myLibrary
        foreign key (operator_id) references mylibrary_librarian_table (staff_id)
);

create table mylibrary_book_table
(
    book_id          int auto_increment
        primary key,
    storage_location varchar(20) not null,
    status           varchar(20) not null,
    isbn_id          varchar(50) not null,
    operator_id      varchar(20) not null,
    constraint myLibrary_book_table_isbn_id_c5251217_fk_myLibrary
        foreign key (isbn_id) references mylibrary_booklist_table (isbn),
    constraint myLibrary_book_table_operator_id_5fa01ab0_fk_myLibrary
        foreign key (operator_id) references mylibrary_librarian_table (staff_id)
);

create table mylibrary_reader_table
(
    reader_id int auto_increment
        primary key,
    password  varchar(256) not null,
    name      varchar(10)  not null,
    phone_num varchar(20)  not null,
    email     varchar(50)  not null,
    arrears   double       not null
);

create table mylibrary_borrow_table
(
    id             int auto_increment
        primary key,
    borrowing_time datetime(6) not null,
    due_date       datetime(6) not null,
    return_date    datetime(6) null,
    book_id_id     int         not null,
    reader_id_id   int         not null,
    constraint myLibrary_borrow_table_reader_id_id_book_id_id__37a2dacd_uniq
        unique (reader_id_id, book_id_id, borrowing_time),
    constraint myLibrary_borrow_tab_book_id_id_e34cd078_fk_myLibrary
        foreign key (book_id_id) references mylibrary_book_table (book_id),
    constraint myLibrary_borrow_tab_reader_id_id_db6582f1_fk_myLibrary
        foreign key (reader_id_id) references mylibrary_reader_table (reader_id)
);

create table mylibrary_recommend_table
(
    isbn            varchar(50) not null
        primary key,
    book_num        int         not null,
    admin_operation varchar(20) null,
    status          varchar(20) not null,
    reader_id_id    int         not null,
    constraint myLibrary_recommend__reader_id_id_43658466_fk_myLibrary
        foreign key (reader_id_id) references mylibrary_reader_table (reader_id)
);

create table mylibrary_reservation_table
(
    id                 int auto_increment
        primary key,
    reservation_date   datetime(6) not null,
    take_date          datetime(6) not null,
    reservation_status varchar(20) not null,
    book_id_id         int         null,
    reader_id_id       int         not null,
    constraint myLibrary_reservation_ta_reader_id_id_book_id_id__ee4916a1_uniq
        unique (reader_id_id, book_id_id, reservation_date),
    constraint myLibrary_reservatio_book_id_id_612d37bb_fk_myLibrary
        foreign key (book_id_id) references mylibrary_book_table (book_id),
    constraint myLibrary_reservatio_reader_id_id_90a00f17_fk_myLibrary
        foreign key (reader_id_id) references mylibrary_reader_table (reader_id)
);

create index myLibrary_reservation_table_reader_id_id_90a00f17
    on mylibrary_reservation_table (reader_id_id);



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


##函数
###查询出当前荐购表中购买数量最大的那一个荐购请求
USE db;
DELIMITER //
CREATE FUNCTION get_recommendation() RETURNS TABLE (isbn_val INT) -- 根据实际情况调整返回值的数据类型
READS SQL DATA
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE isbn_val INT; -- 根据实际情况调整变量的数据类型

    -- 创建游标
    DECLARE cursor_name CURSOR FOR
        SELECT isbn FROM mylibrary_recommend_table WHERE status = '未处理';

    -- 声明异常处理
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- 声明结果集
    DECLARE EXIT HANDLER FOR SQLWARNING, SQLEXCEPTION
    BEGIN
        CLOSE cursor_name;
        DEALLOCATE PREPARE stmt;
        SELECT NULL;
    END;

    -- 打开游标
    OPEN cursor_name;

    -- 获取结果集
    FETCH cursor_name INTO isbn_val;
    WHILE NOT done DO
        -- 返回结果集中的每个ISBN值
        RETURN NEXT isbn_val;
        FETCH cursor_name INTO isbn_val;
    END WHILE;

    -- 关闭游标
    CLOSE cursor_name;

    RETURN;
END//
DELIMITER ;


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

###使用事务的函数 为读者缴费
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

