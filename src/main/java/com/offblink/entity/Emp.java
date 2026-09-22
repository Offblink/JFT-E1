package com.offblink.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.math.BigDecimal;
import java.util.Date;

/**
 * 员工实体类（实验一指导书任务 2.2 / 4.2）
 * 对应数据库表：ssm_emp.employer（老师要求的表名，早期版本为 emp）
 * 注意：指导书原稿在 status 上加了 @TableLogic——status 是业务字段（1在职 0离职），
 * 照抄会把离职员工在 MP 查询里过滤"消失"，故不加（正确做法是独立 deleted 字段）
 *
 * 第 5 章关联映射用到的 deptId / deptInfo / skills 三个关联字段不在本类——那条线已于 2026-09-22
 * 从工作区删除（留档包见 omp 技能 `mybatis01-ch5-relation-mapping`），本类只保留实验一自己的表字段。
 */
@TableName("ssm_emp.employer")
public class Emp {
    @TableId(value = "emp_id", type = IdType.AUTO)
    private Integer empId;
    @TableField("emp_name")
    private String empName;
    private String gender;
    private String dept;
    private String post;
    private BigDecimal salary;
    private Date hireDate;
    private Integer status;

    public Emp() {
    }

    public Integer getEmpId() {
        return empId;
    }

    public void setEmpId(Integer empId) {
        this.empId = empId;
    }

    public String getEmpName() {
        return empName;
    }

    public void setEmpName(String empName) {
        this.empName = empName;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getDept() {
        return dept;
    }

    public void setDept(String dept) {
        this.dept = dept;
    }

    public String getPost() {
        return post;
    }

    public void setPost(String post) {
        this.post = post;
    }

    public BigDecimal getSalary() {
        return salary;
    }

    public void setSalary(BigDecimal salary) {
        this.salary = salary;
    }

    public Date getHireDate() {
        return hireDate;
    }

    public void setHireDate(Date hireDate) {
        this.hireDate = hireDate;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    /** toString 只打本表字段（不打印关联对象） */
    @Override
    public String toString() {
        return "Emp{" +
                "empId=" + empId +
                ", empName='" + empName + '\'' +
                ", gender='" + gender + '\'' +
                ", dept='" + dept + '\'' +
                ", post='" + post + '\'' +
                ", salary=" + salary +
                ", hireDate=" + hireDate +
                ", status=" + status +
                '}';
    }
}
