package com.offblink.entity;

import java.io.Serializable;

/**
 * 技能实体（第 5 章多对多的另一侧）
 * 对应数据库表：ssm_emp.skill，关系经中间表 ssm_emp.employer_skill 连接
 * <p>
 * 同样不是 MyBatis-Plus 实体：只是 collection ofType="Skill" 要的元素类型。
 */
public class Skill implements Serializable {

    private Integer id;
    private String name;
    private String description;

    public Skill() {
    }

    public Skill(Integer id, String name, String description) {
        this.id = id;
        this.name = name;
        this.description = description;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return "Skill{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                '}';
    }
}
