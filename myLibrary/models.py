from django.db import models


class reader_table(models.Model):  # 读者信息
    reader_id = models.AutoField(primary_key=True)  # 读者ID
    password = models.CharField(max_length=256)  # 读者密码
    name = models.CharField(max_length=10)  # 姓名
    phone_num = models.CharField(max_length=20)  # 电话
    email = models.CharField(max_length=50)  # 邮箱
    arrears = models.DecimalField(default=0.0, max_digits=10, decimal_places=2)  # 所欠款项,还书时更新
    def save(self, force_insert=False, force_update=False, using=None, update_fields=None):
        result = reader_table.objects.filter(email=self.email)
        assert not result.exists(), '邮箱已被注册'
        super(reader_table, self).save(force_insert, force_update, using, update_fields)
    def admin_return_save(self, force_insert=False, force_update=False, using=None, update_fields=None):
        #result = reader_table.objects.filter(email=self.email)
        #assert not result.exists(), '邮箱已被注册'
        super(reader_table, self).save(force_insert, force_update, using, update_fields)

class librarian_table(models.Model):  # 图书管理员信息
    staff_id = models.CharField(max_length=20, primary_key=True)  # 工号，格式：staff_id001
    password = models.CharField(max_length=256)  # 管理员密码
    name = models.CharField(max_length=10)  # 姓名

    def save(self, force_insert=False, force_update=False, using=None, update_fields=None):
        assert str(self.staff_id).startswith('staff_id')
        super(librarian_table, self).save(force_insert, force_update, using, update_fields)


class booklist_table(models.Model):  # 书目信息
    isbn = models.CharField(max_length=50, primary_key=True)  # ISBN号
    book_name = models.CharField(max_length=50)  # 书名
    author = models.CharField(max_length=50)  # 作者
    publisher = models.CharField(max_length=50)  # 出版商
    publish_date = models.DateTimeField()  # 出版年月
    # num = models.IntegerField()   # 册数
    operator = models.ForeignKey(librarian_table, on_delete=models.CASCADE)  # 经办人
    # add
    image = models.ImageField(null=True, blank=True, upload_to='fig/')
    pdf = models.FileField(upload_to='pdf/', null=True, blank=True, )
    vedio = models.FileField(upload_to='vedio/', null=True)


class book_table(models.Model):  # 图书信息
    book_id = models.AutoField(primary_key=True)  # 图书id
    isbn = models.ForeignKey(booklist_table, on_delete=models.CASCADE)  # ISBN号
    storage_location = models.CharField(max_length=20)  # 存放位置(图书流通室、图书阅览室)
    status = models.CharField(max_length=20)  # 状态（未借出、已借出、不外借、已预约）
    operator = models.ForeignKey(librarian_table, on_delete=models.CASCADE)  # 经办人

    def save(self, force_insert=False, force_update=False, using=None, update_fields=None):
        assert self.storage_location in ('图书流通室', '图书阅览室'), '存放位置必须为图书流通室或图书阅览室'
        assert self.status in ('未借出', '已借出', '不外借', '已预约'), '书本状态必须是未借出、已借出、不外借、已预约'
        super(book_table, self).save(force_insert, force_update, using, update_fields)

    def delete(self, using=None, keep_parents=False):  # 出库触发器
        assert self.status != '已借出', '已借出图书不允许出库'
        super(book_table, self).delete(using, keep_parents)


class borrow_table(models.Model):  # 借书信息
    reader_id = models.ForeignKey(reader_table, on_delete=models.PROTECT)  # 读者ID
    book_id = models.ForeignKey(book_table, on_delete=models.PROTECT)  # 图书ID
    borrowing_time = models.DateTimeField()  # 借阅时间
    due_date = models.DateTimeField()  # 应还时间
    return_date = models.DateTimeField(blank=True, null=True)  # 归还时间

    def save(self, force_insert=False, force_update=False, using=None, update_fields=None):
        assert self.borrowing_time < self.due_date, '归还时间应在借阅时间之后'
        super(borrow_table, self).save(force_insert, force_update, using, update_fields)

    class Meta:
        unique_together = ("reader_id", "book_id", "borrowing_time")


class reservation_table(models.Model):  # 预约信息
    reader_id = models.ForeignKey(reader_table, on_delete=models.CASCADE)  # 读者ID
    #isbn = models.ForeignKey(booklist_table, on_delete=models.CASCADE)  # ISBN号
    book_id = models.ForeignKey(book_table, blank=True, null=True, on_delete=models.CASCADE)  # 图书ID
    reservation_date = models.DateTimeField()  # 预约时间
    take_date = models.DateTimeField()  # 预约取书时间
    reservation_status = models.CharField(max_length=20, default='未处理')  # 状态（已处理、未处理）

    def save(self, force_insert=False, force_update=False, using=None, update_fields=None):  # 创建预约触发器
        super(reservation_table, self).save(force_insert, force_update, using, update_fields)

    class Meta:
        unique_together = ("reader_id", "book_id", "reservation_date")


# 建购信息表
class recommend_table(models.Model):
    reader_id = models.ForeignKey(reader_table, on_delete=models.PROTECT)  # 读者ID
    isbn = models.CharField(max_length=50, primary_key=True)  # ISBN号
    book_num = models.IntegerField()  # 册数
    admin_operation = models.CharField(max_length=20, null=True)  # 管理员操作 同意荐购 不同意荐购
    status = models.CharField(max_length=20, default='未处理')  # 状态（已处理、未处理）
