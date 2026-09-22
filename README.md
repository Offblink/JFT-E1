# JFT-E1 · 实验一（MyBatis / MyBatis-Plus）+ 第 5 章关联映射

《JAVA框架技术（一）》（AI 赋能版）课程项目。以 AI 辅助、人脑主导的方式完成，全程保留开发轨迹
（Git 提交历史即过程记录）。

**一个实验一个项目**：本项目是 **实验一**，因此叫 `JFT-E1`（本地目录 `~/IdeaProjects/JFT-E1`、
Maven 坐标 `com.offblink:JFT-E1`、war 产物 `JFT-E1.war`），里面还带一条第 5 章「关联映射与多表查询」的专项练习线。
后续的实验二（SSM 整合 + EMP MIS）会另起项目。
注意两层命名不要混：`e1` = 实验一这个项目，`01` = 课程编号（课程仓 `Offblink/JFT-01` 收的是这门课的东西）。

## 源码怎么分（按实验/章分包）

```
com.offblink.entity     跨线共用实体：User / Vo（实验一）、Emp（两条线都用）、Dept / Skill（第 5 章）
com.offblink.util       MyBatisUtil —— 会话工厂（通用工厂 + MP 分页专用工厂）
com.offblink.lab01      实验一：UserMapper、UserMapperAnnotation、EmpMapper（MP 线）
com.offblink.chapter05  第 5 章：EmpRelationMapper、DeptRelationMapper（XML + 注解两套关联查询）
```

Mapper 接口与它的 XML **同包同名**放在一起（`src/main/resources/com/offblink/<同一个包>/Xxx.xml`），
`mybatis-config.xml` 里每个包一行 `<package name="com.offblink.xxx"/>` 扫包注册，不再手写
`<mapper resource>` / `<mapper class>`。新增一个实验就加一个包 + 一行注册，互不干扰。

## 技术栈

| 类别 | 选型 |
|---|---|
| 语言 / JDK | Java 8 语法目标（IDEA 运行 JDK 见下） |
| 构建 | Maven 3.9.x（阿里云镜像），war 打包（产物 `JFT-E1.war`） |
| 持久层 | MyBatis-Plus 3.5.3.1（内置 MyBatis 3.5.10，`EmpMapper extends BaseMapper`） |
| 数据库 | MySQL 8/9（`mysql-connector-j` 8.0.33） |
| 测试 | JUnit 4.13.2 |
| 日志 | SLF4J 门面 + Logback 1.2.13（控制台 + 滚动文件双输出） |
| Web | JavaEE（javax.servlet-api 4.0.1，web.xml） |

## 功能

**实验一（`com.offblink.lab01`，38 个用例）**

- 用户表完整 CRUD：`findAll` / `findById` / `addUser`（自增主键回填）/ `updateUser` / `deleteUser`
- 用户名模糊查询 `findByUsernameLike`（`LIKE CONCAT('%', #{keyword}, '%')` 预编译防注入）
- 生命周期测试：以回填的主键 id 贯穿增→改→查→删，无顺序依赖，跑完自清理
- 结果映射（第 4 节）：
  - XML 侧三连对照——① `findAllWithColumnAlias`（别名 `uid` 对不上属性名 `id`，resultType 丢字段）、
    ② `findAllByVoWithResultType`（别名即契约，靠 `p1/p2/p3` 对上 VO）、③ `findAllByVoMap`（`resultMap` 集中声明映射规则）
  - 注解侧两式——`@Results` 匿名映射成 VO；`@Results(id="annoUserMap")` 命名后由 `@ResultMap("annoUserMap")` 复用
- 动态 SQL（第 4-2 节）：
  - XML 六种标签：`<if>`+`<where>` 条件组合、`<set>` 选择性更新、`<choose>` 互斥分支、
    `<foreach>` IN 查询与一条 INSERT 批量插入、`<trim>` 自定义裁剪、`<sql>`+`<include>` 片段复用
  - 注解线：`<script>` 包住动态标签的写法，以及注解 SQL 用全限定名 `@ResultMap` 跨方式引用 XML 的 `userResultMap`
- MyBatis-Plus：`BaseMapper` 零 SQL CRUD、`LambdaQueryWrapper`、分页插件（`MybatisPlusInterceptor` 代码注册）
- emp 载体（指导书任务 2/3 要求）：`ssm_emp.employer` 表 + `EmpMapper`（resultMap / sql 片段 / 批量插入 /
  `<foreach>` IN 按岗位查询 / 分号拼多条 UPDATE 的一次性批量更新）

**第 5 章（`com.offblink.chapter05`，9 个用例）**

| 关系 | XML 方式（嵌套结果，1 条 SQL） | 注解方式（嵌套 select，1+N 条） |
|---|---|---|
| 一对一 / 多对一 | `EmpRelationMapper.one2oneByXml` / `many2oneByXml`（共用 `empWithDeptMap`） | `one2oneByAnn` / `many2oneByAnn`（`@One`） |
| 一对多 | `DeptRelationMapper.one2manyByXml`（`<collection ofType="Emp">`） | `one2manyByAnn`（`@Many`） |
| 多对多 | `EmpRelationMapper.many2manyByXml`（两次 JOIN 穿中间表） | `many2manyByAnn`（`@Many` 调 `selectSkillsByEmpId`） |

实测结论（SQL 条数、与讲义不一致的三处）见 [docs/第5章/关联映射实测记录.md](docs/第5章/关联映射实测记录.md)。

## 快速开始

```bash
# 1. 建库建表（MySQL 8+）——实验一建库建表在前，第 5 章的关联三表在其后执行
mysql -u root -p < sql/实验一/user_db.sql
mysql -u root -p < sql/实验一/ssm_emp.sql
mysql -u root -p < sql/第5章/dept_skill.sql     # 可重复执行（补 dept/skill/employer_skill + employer.dept_id）

# 2. 配置数据库连接（占位符改为你自己的本地配置）
#    src/main/resources/db.properties

# 3. 跑全量测试（当前 47 个用例）
mvn test
```

> `db.properties` 仓库内为占位配置（`jdbc.password=CHANGE_ME`），本地实际配置不提交（skip-worktree），
> 请勿将真实口令提交到仓库。
>
> 其中 JDBC URL 需要 `allowMultiQueries=true`（批量更新 `updateBatch` 用 `<foreach>` 分号拼多条 UPDATE，
> 不开这个开关驱动会直接报语法错误）；`allowPublicKeyRetrieval=true` 是 MySQL 8/9 在 `useSSL=false` 下必须的。

## 项目结构

```
JFT-e1/
├── sql/
│   ├── 实验一/{user_db.sql, ssm_emp.sql}          # mybatis_db / ssm_emp 建库建表 + 种子数据
│   └── 第5章/dept_skill.sql                       # dept / skill / employer_skill 中间表 + employer.dept_id
├── src/main/java/com/offblink/
│   ├── entity/{User, Vo, Emp}.java                # 实验一实体（Emp 同时是第 5 章的"多"方）
│   ├── entity/{Dept, Skill}.java                  # 第 5 章：关联映射的"一方"与多对多另一侧
│   ├── lab01/{UserMapper, UserMapperAnnotation, EmpMapper}.java          # 实验一（MP 也在这一包）
│   ├── chapter05/{EmpRelationMapper, DeptRelationMapper}.java            # 第 5 章：XML + 注解两套关联查询
│   └── util/MyBatisUtil.java                      # 会话工厂（通用工厂 + MP 分页专用工厂）
├── src/main/resources/
│   ├── db.properties                              # 连接配置（占位，skip-worktree）
│   ├── mybatis-config.xml                         # logImpl=SLF4J、驼峰、typeAliases、延迟加载、两行 <package> 注册
│   ├── logback.xml                                # 日志：控制台 + logs/mybatis.log 滚动文件（com.offblink 整包 DEBUG）
│   ├── com/offblink/lab01/{UserMapper, EmpMapper}.xml        # 与接口同包同名
│   └── com/offblink/chapter05/{EmpRelationMapper, DeptRelationMapper}.xml
├── src/main/webapp/                               # JavaEE web 骨架
├── src/test/java/com/offblink/
│   ├── lab01/{UserMapperTest, UserMapperAnnotationTest, EmpMapperTest, EmpMapperMpTest}.java
│   └── chapter05/EmpRelationMapperTest.java
└── docs/                                          # 过程材料（报告草稿、会话回顾、排查演练、章节实测记录）
```

## 文档

- 实验一：[实验报告草稿](docs/实验一/实验报告-实验一-草稿.md) ｜
  [会话回顾](docs/实验一/会话回顾-实验一-20260901.md)（AI 辅助开发全程记录与人工校验过程）｜
  [日志排查演练](docs/实验一/日志排查演练-实验一.md)
- 第 5 章：[关联映射实测记录](docs/第5章/关联映射实测记录.md)（两套实现的 SQL 条数、三处与讲义不一致的实测结论）

## License

[MIT](LICENSE)
