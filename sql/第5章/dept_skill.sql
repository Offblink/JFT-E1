-- 第 5 章（关联映射与多表查询）业务载体：在实验一的 ssm_emp 库上补「能连表」的那几张表
-- 定位：课件章节练习，不属于实验一交付；借住在实验一项目里只因复用它的库与实体，实验二立项时整体搬走
-- 对应老师的 emp / dept / skill / emp_skill（本项目员工表按老师要求叫 employer）
-- 与 ssm_emp.sql 一样做成可重复执行：建表用 IF NOT EXISTS，加列用 information_schema 先探再改

USE ssm_emp;

-- ==================== 1. 部门表：员工的"一方" ====================
-- 老师用的是 scott 的 dept(deptno, dname, loc)；这里按本项目风格命名，
-- 主键手工指定（10/20/30）而不是自增，方便建表脚本与种子数据对齐、方便直接按编号查询
CREATE TABLE IF NOT EXISTS dept (
    dept_id   INT PRIMARY KEY COMMENT '部门编号',
    dept_name VARCHAR(50) NOT NULL COMMENT '部门名称',
    loc       VARCHAR(50) COMMENT '办公地点'
) COMMENT '部门表：与 employer 构成 多对一 / 一对多 关系';

-- ==================== 2. 技能表 + 中间表：多对多 ====================
-- 一项技能可以被多个员工掌握、一个员工可以掌握多项技能 → 关系型数据库无法用外键直接表达，
-- 必须引入中间表 employer_skill（联合主键 = 两条外键，本身就是"关系"的载体）
CREATE TABLE IF NOT EXISTS skill (
    id          INT PRIMARY KEY AUTO_INCREMENT COMMENT '技能编号',
    name        VARCHAR(50) NOT NULL COMMENT '技能名称',
    description VARCHAR(255) COMMENT '技能说明'
) COMMENT '技能表';

CREATE TABLE IF NOT EXISTS employer_skill (
    emp_id   INT NOT NULL COMMENT '员工编号（外键 → employer.emp_id）',
    skill_id INT NOT NULL COMMENT '技能编号（外键 → skill.id）',
    PRIMARY KEY (emp_id, skill_id),
    CONSTRAINT fk_es_emp   FOREIGN KEY (emp_id)   REFERENCES employer (emp_id),
    CONSTRAINT fk_es_skill FOREIGN KEY (skill_id) REFERENCES skill (id)
) COMMENT '员工-技能中间表：多对多的物理落点';

-- ==================== 3. employer 补外键列 dept_id ====================
-- 实验一的 employer 只有一个部门"文本"列 dept（'研发部'），没有外键就没什么可关联的，
-- 所以这里补一个真正的 dept_id。MySQL 的 ADD COLUMN 不支持 IF NOT EXISTS（那是 MariaDB 的扩展），
-- 于是先用 information_schema 探一次，再决定拼哪条 DDL —— 整段重复执行不会报 1060 列已存在。
SET @has_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
                 WHERE TABLE_SCHEMA = 'ssm_emp' AND TABLE_NAME = 'employer' AND COLUMN_NAME = 'dept_id');
SET @ddl := IF(@has_col = 0,
               'ALTER TABLE employer ADD COLUMN dept_id INT NULL COMMENT ''所属部门编号（外键 → dept.dept_id）'' AFTER dept',
               'SELECT ''employer.dept_id 已存在，跳过加列'' AS note');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 外键约束同样先探再加（约束名固定，重建库时才可能缺）
SET @has_fk := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
                WHERE TABLE_SCHEMA = 'ssm_emp' AND TABLE_NAME = 'employer'
                  AND CONSTRAINT_NAME = 'fk_emp_dept' AND CONSTRAINT_TYPE = 'FOREIGN KEY');
SET @ddl := IF(@has_fk = 0,
               'ALTER TABLE employer ADD CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES dept (dept_id)',
               'SELECT ''外键 fk_emp_dept 已存在，跳过'' AS note');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ==================== 4. 种子数据（可重复执行：先删关系再插） ====================
-- 注意顺序：被引用的先插（dept / skill），引用的后插（employer_skill）
INSERT INTO dept (dept_id, dept_name, loc) VALUES
(10, '研发部', '北京'),
(20, '市场部', '上海'),
(30, '人事部', '广州')
ON DUPLICATE KEY UPDATE dept_name = VALUES(dept_name), loc = VALUES(loc);

INSERT INTO skill (id, name, description) VALUES
(1, 'Java',   '后端开发'),
(2, 'MySQL',  '数据库'),
(3, 'Vue',    '前端框架'),
(4, 'Axure',  '原型设计')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

-- 把实验一已有的部门文本列映射成外键（文本列保留不动：实验一的 XML/MP 用例都还在用它）
UPDATE employer e JOIN dept d ON e.dept = d.dept_name SET e.dept_id = d.dept_id;

-- 员工-技能关系：张伟(1) 掌握 Java+MySQL，李娜(2) 会 Vue，王强(3) 会 Axure，
-- 赵敏(4) 故意一条都不给 —— 留给多对多的 LEFT JOIN 用例看"没有技能的人"长什么样
DELETE FROM employer_skill WHERE emp_id IN (SELECT emp_id FROM employer);
INSERT INTO employer_skill (emp_id, skill_id)
SELECT e.emp_id, s.id
FROM employer e JOIN skill s
  ON (e.emp_id = 1 AND s.name IN ('Java', 'MySQL'))
  OR (e.emp_id = 2 AND s.name = 'Vue')
  OR (e.emp_id = 3 AND s.name = 'Axure');
