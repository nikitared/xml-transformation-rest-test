package ru.babaninnv.edisoft.test.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

/**
 * Сущность XML-файл для хранения в БД  и передачи на клиент
 *
 * @author Nikita Babanin
 * @version 1.0
 */
@Entity
@JsonInclude(JsonInclude.Include.NON_NULL)
public class XmlFile {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    private String originalName;

    @JsonFormat(pattern="dd-MM-yyyy hh:mm:ss")
    private Date receiveDate;

    @Column(columnDefinition = "BLOB")
    private byte[] originalFile;

    @Column(columnDefinition = "BLOB")
    private byte[] transformedFile;

    public XmlFile() {
    }

    public XmlFile(Long id, String originalName, Date receiveDate) {
        this.id = id;
        this.originalName = originalName;
        this.receiveDate = receiveDate;
    }

    public XmlFile(String originalName, byte[] transformedFile) {
        this.originalName = originalName;
        this.transformedFile = transformedFile;
    }

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public String getOriginalName() {
        return originalName;
    }
    public void setOriginalName(String originalName) {
        this.originalName = originalName;
    }

    public Date getReceiveDate() {
        return receiveDate;
    }
    public void setReceiveDate(Date receiveDate) {
        this.receiveDate = receiveDate;
    }

    public byte[] getOriginalFile() {
        return originalFile;
    }
    public void setOriginalFile(byte[] originalFile) {
        this.originalFile = originalFile;
    }

    public byte[] getTransformedFile() {
        return transformedFile;
    }
    public void setTransformedFile(byte[] transformedFile) {
        this.transformedFile = transformedFile;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof XmlFile)) return false;

        XmlFile xmlFile = (XmlFile) o;

        if (!id.equals(xmlFile.id)) return false;
        return originalName.equals(xmlFile.originalName);
    }

    @Override
    public int hashCode() {
        int result = id.hashCode();
        result = 31 * result + originalName.hashCode();
        return result;
    }
}
