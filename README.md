# JFT-E1 · 实验一（MyBatis / MyBatis-Plus）

《JAVA框架技术（一）》（AI 赋能版）课程项目。以 AI 辅助、人脑主导的方式完成，全程保留开发轨迹
（Git 提交历史即过程记录）。

**一个实验一个项目**：本项目是 **实验一**，因此叫 `JFT-E1`（本地目录 `~/IdeaProjects/JFT-E1`、
Maven 坐标 `com.offblink:JFT-E1`、war 产物 `JFT-E1.war`）。后续的实验二（SSM 整合 + EMP MIS）会另起项目。

命名与归属别混：

| 名字 | 是什么 |
|---|---|
| `E1` | **实验一这个项目**（本仓，`Offblink/JFT-E1`） |
| `01` | **课程编号**（课程仓 `Offblink/JFT-01`，装课程层的东西） |
| 第 5 章「关联映射」 | **课件章节练习，本项目不含**：2026-09-22 先拆成独立项目、随后按你的要求从工作区删除（技术结论留在 omp 技能库；可恢复包 `C:\Users\37549\Tools\attic\JFT-Ch05-20260922.bundle`） |

## 源码怎么分

```
com.offblink.entity     User / Vo / Emp —— 实验一的实体
com.offblink.util       MyBatisUtil —— 会话工厂（通用工厂 + MP 分页专用工厂）
com.offblink.lab01      实验一：UserMapper、UserMapperAnnotation、EmpMapper（MP 线）
```

Mapper 接口与它的 XML **同包同名**放在一起（`src/main/resources/com/offblink/lab01/Xxx.xml`），
`mybatis-config.xml` 用一行 `<package name="com.offblink.lab01"/>` 扫包注册，不再手写
`<mapper resource>` / `<mapper class>`。放错位置编译期不报错、跑用例才炸 `Invalid bound statement`。

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

## 功能（`com.offblink.lab01`，38 个用例）

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

## 快速开始

```bash
# 1. 建库建表（MySQL 8+）
mysql -u root -p < sql/实验一/user_db.sql
mysql -u root -p < sql/实验一/ssm_emp.sql

# 2. 配置数据库连接（占位符改为你自己的本地配置）
#    src/main/resources/db.properties

# 3. 跑全量测试（38 个用例）
mvn test
```

> `db.properties` 仓库内为占位配置（`jdbc.password=CHANGE_ME`），本地实际配置不提交（skip-worktree），
> 请勿将真实口令提交到仓库。
>
> 其中 JDBC URL 需要 `allowMultiQueries=true`（批量更新 `updateBatch` 用 `<foreach>` 分号拼多条 UPDATE，
> 不开这个开关驱动会直接报语法错误）；`allowPublicKeyRetrieval=true` 是 MySQL 8/9 在 `useSSL=false` 下必须的。

## 项目结构

```
JFT-E1/
├── sql/实验一/{user_db.sql, ssm_emp.sql}          # mybatis_db / ssm_emp 建库建表 + 种子数据
├── src/main/java/com/offblink/
│   ├── entity/{User, Vo, Emp}.java                # 实验一实体
│   ├── lab01/{UserMapper, UserMapperAnnotation, EmpMapper}.java   # 实验一 Mapper（MP 也在这个包）
│   └── util/MyBatisUtil.java                      # 会话工厂（通用工厂 + MP 分页专用工厂）
├── src/main/resources/
│   ├── db.properties                              # 连接配置（占位，skip-worktree）
│   ├── mybatis-config.xml                         # logImpl=SLF4J、驼峰、typeAliases、延迟加载、一行 <package> 注册
│   ├── logback.xml                                # 日志：控制台 + logs/mybatis.log 滚动文件（com.offblink 整包 DEBUG）
│   └── com/offblink/lab01/{UserMapper, EmpMapper}.xml    # 与接口同包同名
├── src/main/webapp/                               # JavaEE web 骨架
├── src/test/java/com/offblink/lab01/              # UserMapperTest / UserMapperAnnotationTest
│   │                                              # EmpMapperTest / EmpMapperMpTest
└── docs/实验一/                                   # 报告草稿、会话回顾、日志排查演练
```

## 文档

- [实验报告草稿](docs/实验一/实验报告-实验一-草稿.md)
- [会话回顾](docs/实验一/会话回顾-实验一-20260901.md) —— AI 辅助开发全程记录与人工校验过程
- [日志排查演练](docs/实验一/日志排查演练-实验一.md)


## License

[MIT](LICENSE)
