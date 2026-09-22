package com.offblink.entity;

import java.io.Serializable;
import java.util.List;

/**
 * 部门实体（第 5 章关联映射的"一方"）
 * 对应数据库表：ssm_emp.dept
 * 与实验一的 Emp 不同，这个类不是 MyBatis-Plus 实体（没有 @TableName/@TableId）：
 * 它只服务本章的关联查询，字段与 dept 表一一对应，另外多一个 {@link #emps} 用来装
 * 一对多查询出来的员工集合 —— 映射标签 collection 的 property 就指向它。
 */
public class Dept implements Serializable {

    private Integer deptId;
    private String deptName;
    private String loc;

    // 定义这个属性，用于表连接
    /** 一对多：一个部门下有多个员工（&lt;collection&gt; / @Many 的落点） */
    private List<Emp> emps;

    public Dept() {
    }

    public Integer getDeptId() {
        return deptId;
    }

    public void setDeptId(Integer deptId) {
        this.deptId = deptId;
    }

    public String getDeptName() {
        return deptName;
    }

    public void setDeptName(String deptName) {
        this.deptName = deptName;
    }

    public String getLoc() {
        return loc;
    }

    public void setLoc(String loc) {
        this.loc = loc;
    }

    public List<Emp> getEmps() {
        return emps;
    }

    public void setEmps(List<Emp> emps) {
        this.emps = emps;
    }

    /** 故意不打印 emps：一对多打印整个集合会刷屏，名单由用例自己遍历输出 */
    @Override
    public String toString() {
        return "Dept{" +
                "deptId=" + deptId +
                ", deptName='" + deptName + '\'' +
                ", loc='" + loc + '\'' +
                '}';
    }
}
